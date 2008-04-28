<%
my $f = $Request->Form();
my $run_dir = Octopussy::Directory("running");
my $login = $Session->{AAT_LOGIN};
my $msg_nb_lines = AAT::Translation("_MSG_NB_LINES");
my $LINES_BY_PAGE = 1000;
my $nb_lines = 0;
my $last_page = 1;
my $text = "";
my $url = "./logs_viewer.asp";

my @devices = AAT::ARRAY($Session->{device});
my @services = AAT::ARRAY($Session->{service});

my $page = $Session->{page} || 1;
my $dt = $Session->{dt};
my ($d1, $m1, $y1, $hour1, $min1) = 
	($Session->{dt1_day}, $Session->{dt1_month}, $Session->{dt1_year}, 
	$Session->{dt1_hour}, $Session->{dt1_min});
my ($d2, $m2, $y2, $hour2, $min2) = 
	($Session->{dt2_day}, $Session->{dt2_month}, $Session->{dt2_year},
	$Session->{dt2_hour}, $Session->{dt2_min});
my ($re_include, $re_include2, $re_include3) = 
	($Session->{re_include}, $Session->{re_include2}, $Session->{re_include3});
my ($re_exclude, $re_exclude2, $re_exclude3) = 
	($Session->{re_exclude}, $Session->{re_exclude2}, $Session->{re_exclude3});

if (AAT::NOT_NULL($Session->{cancel}))
{
	my $pid_param = $Session->{extracted};
  my $pid_file = $run_dir . "octo_extractor_${pid_param}.pid";
	$pid = `cat "$pid_file"`;
	kill USR2 => $pid;
	($Session->{extractor}, $Session->{cancel}, $Session->{logs}, 
	$Session->{file}, $Session->{csv}, $Session->{zip}) =
    (undef, undef, undef, undef, undef, undef);	
}

if (AAT::NOT_NULL($f->{template}))
{
	if (AAT::NOT_NULL($f->{template_save}))
	{
		$re_include =~ s/\\/\\\\/g;
  	$re_include2 =~ s/\\/\\\\/g;
  	$re_include3 =~ s/\\/\\\\/g;
  	$re_exclude =~ s/\\/\\\\/g;
  	$re_exclude2 =~ s/\\/\\\\/g;
  	$re_exclude3 =~ s/\\/\\\\/g;
  	Octopussy::Search_Template::New($login, { name => $Session->{template},
  		device => \@devices, service => \@services,
  		re_include => $re_include, re_include2 => $re_include2,
  		re_include3 => $re_include3, re_exclude => $re_exclude,
  		re_exclude2 => $re_exclude2, re_exclude3 => $re_exclude3 } );		
	}
	elsif (AAT::NOT_NULL($f->{template_remove}))
		{ Octopussy::Search_Template::Remove($login, $f->{template}); }
}

if ((AAT::NULL($Session->{extractor})) && 
		((AAT::NOT_NULL($Session->{logs})) || (AAT::NOT_NULL($Session->{file})) 
			|| (AAT::NOT_NULL($Session->{csv})) || (AAT::NOT_NULL($Session->{zip})))
	&& (($#devices >= 0) && ($#services >= 0) 
	&& ($devices[0] ne "") && ($services[0] ne "")))
{
	use Crypt::PasswdMD5;
	my $output = unix_md5_crypt(time() * rand(99));
	$output =~ s/[\/\&\$\.\?]//g;
	my $cmd = Octopussy::Logs::Extract_Cmd_Line( { 
		devices => \@devices, services =>\@services, 
		begin => "$y1$m1$d1$hour1$min1", end => "$y2$m2$d2$hour2$min2",
		includes => [$re_include, $re_include2, $re_include3],
		excludes => [$re_exclude, $re_exclude2, $re_exclude3],
		pid_param => $output, output => "$run_dir/logs_${login}_$output" } );
	$Session->{export} = 
		"logs_" . join("-", @devices) . "_" . join("-", @services)
    	. "_$y1$m1$d1$hour1$min1" . "-$y2$m2$d2$hour2$min2";
	system("$cmd &");
	my $status_file = $run_dir . "octo_extractor_${output}.status";
	open(STATUS_FILE, "> $status_file");
  print STATUS_FILE "INIT [0/1] [0]\n";
  close(STATUS_FILE);
	$Session->{extract_progress_current} = 0;
  $Session->{extract_progress_total} = 0;
  $Session->{extract_progress_match} = 0;	
	$Session->{page} = 1;
	$Session->{extracted} = $output;
	$Response->Redirect("$url?extractor=$output");
}

if ($Session->{extractor} eq "done")
{
	if (AAT::NOT_NULL($Session->{file}) || AAT::NOT_NULL($Session->{csv})
		|| AAT::NOT_NULL($Session->{zip}))
	{
		$Response->Redirect("./export_extract.asp");
	}
	else
	{
		my $filename = $Session->{extracted};
		$text = "<table id=\"resultsTable\">";
		my $page = $Session->{page} || 1;
		open(FILE, "< $run_dir/logs_${login}_$filename");
    while (<FILE>)
    {
			if (($nb_lines >= ($page-1)*$LINES_BY_PAGE) 
					&& ($nb_lines <= ($page*$LINES_BY_PAGE)))
			{
				my $line = $Server->HTMLEncode($_);
				$line =~ s/($re_include)/<font color="red"><b>$1<\/b><\/font>/g	
					if (AAT::NOT_NULL($re_include));
				$line =~ s/($re_include2)/<font color="green"><b>$1<\/b><\/font>/g
					if (AAT::NOT_NULL($re_include2));
				$line =~ s/($re_include3)/<font color="blue"><b>$1<\/b><\/font>/g
          if (AAT::NOT_NULL($re_include3));
				$line =~ s/(\S{120})(\S+?)/$1\n$2/g;
				$text .= "<tr class=\"boxcolor" . ($nb_lines%2+1) . "\"><td>$line</td></tr>";
			}
   		$nb_lines++;
  	}
		close(FILE);
		$last_page = int($nb_lines/$LINES_BY_PAGE) + 1;
		$text .= "</table>"; 
	}
	($Session->{cancel}, $Session->{extractor}, $Session->{logs}) = 
		(undef, undef, undef);
}

if ((AAT::NOT_NULL($Session->{extractor})) && ($Session->{extractor} ne "done"))
{
%><WebUI:PageTop title="Logs" onLoad="extract_progress()" />
	<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
	<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
	<script type="text/javascript" src="INC/octo_logs_viewer_progressbar.js"> 
	</script><%
}
else
{
%><WebUI:PageTop title="Logs" />
	<script type="text/javascript" src="INC/octo_logs_viewer_quick_search.js">
	</script><%
}
my @restricted_services = Octopussy::Service::List_Used();
$Response->Include("INC/octo_logs_viewer_form.inc", url => $url, unknown => 1,
	devices => \@devices, services => \@services,
	restricted_services => \@restricted_services);
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="3">
	<AAT:Label value="_QUICK_SEARCH_ON_THIS_PAGE" style="B" />
	<input id="filter" size="30" style="color:orange" onkeydown="Timer();" />
	<AAT:Label value="$msg_nb_lines" style="B"/>
	<span id="nb_lines"><b><%= $nb_lines %></b></span>
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><div id="progressbar_cancel"></div></AAT:BoxCol>
	<AAT:BoxCol><div id="progressbar_bar"></div></AAT:BoxCol>
	<AAT:BoxCol><div id="progressbar_progress"></div></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="3">
<% 
$Response->Include("INC/octo_page_navigator.inc", 
	url => "$url?extractor=done&extracted=" . $Session->{extracted}, 
	page => $page, page_last => $last_page)	if ($last_page > 1);
%>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><%= $text %></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3">
<% 
$Response->Include("INC/octo_page_navigator.inc",
  url => "$url?extractor=done&extracted=" . $Session->{extracted},
  page => $page, page_last => $last_page)	if ($last_page > 1);
%>
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />

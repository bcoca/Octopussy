<WebUI:PageTop title="_LOGS_AVAILABILITY" help="" />
<%
my $q = $Request->Params();
my ($device, $year, $month, $day, $hour) = 
	($q->{device}, $q->{year}, $q->{month}, $q->{day}, $q->{hour});

my ($y, $m) = AAT::Datetime::Now();
$year ||= $y;
#$month ||= $m;

my @devices = Octopussy::Device::List();
%>
<AAT:Form action="logs_availability.asp">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol align="C">
	<AAT:Selector name="device" list=\@devices selected="$device" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C">
	<AAT:Form_Submit value="Check Availability for this device" />
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
if (AAT::NOT_NULL($device))
{
	if (AAT::NOT_NULL($hour))
	{
	%><AAT:Inc file="octo_logs_availability_hour" device="$device" 
  	year="$year" month="$month" day="$day" hour="$hour" /><%	
	}
	elsif (AAT::NOT_NULL($day))
	{
	%><AAT:Inc file="octo_logs_availability_day" device="$device" 
		year="$year" month="$month" day="$day" /><%
	}
	elsif (AAT::NOT_NULL($month))
	{
	%><AAT:Inc file="octo_logs_availability_month" device="$device" 
    year="$year" month="$month" /><%
	}
	elsif (AAT::NOT_NULL($year))
	{
	%><AAT:Inc file="octo_logs_availability_year" device="$device" 
   	year="$year" /><%
	}
}
%>
<WebUI:PageBottom />
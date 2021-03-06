<WebUI:PageTop title="Wizard Search Service" />
<%
my $device = $Request->QueryString("device");
$device = (Octopussy::Device::Valid_Name($device) ? $device : undef);
my $msg = $Request->QueryString("msg");
my $url = "./device_services.asp?device=$device";
my $match = 0;
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="3"><AAT:Label value="$msg" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $serv (Octopussy::Service::List())
{
    my @msg_to_parse = ();
    my @messages = Octopussy::Service::Messages($serv);
    foreach my $m (@messages)
    {
      my $regexp = Octopussy::Message::Pattern_To_Regexp($m);
			if ($msg =~ /^$regexp\s*[^\t\n\r\f -~]?$/i)
			{
        my $msg_color = Octopussy::Message::Color($m->{pattern});
				$match = 1;
				%><AAT:BoxRow>
        <AAT:BoxCol><AAT:Label value="_SERVICE" />:
        <b><%= $serv %></b></AAT:BoxCol>
        <AAT:BoxCol><AAT:Label value="_MSG_ID" />:
        <b><%= $m->{msg_id} %></b></AAT:BoxCol>
        <AAT:BoxCol align="R" rspan="2">
        <AAT:Button name="add" link="${url}&service=$serv" tooltip="_ADD_SERVICE_TO_DEVICE" /></AAT:BoxCol>
        </AAT:BoxRow>
        <AAT:BoxRow>
        <AAT:BoxCol cspan="2"><AAT:Label value="$msg_color" size="-2" /></AAT:BoxCol>
				</AAT:BoxRow><%
			}
    }
}
if (!$match)
{
	%><AAT:BoxRow><AAT:BoxCol cspan="3" align="C">
	<AAT:Label value="No Matching Service !" link="./wizard.asp?device=$device" />
	</AAT:BoxCol></AAT:BoxRow><%
}
%>
</AAT:Box>

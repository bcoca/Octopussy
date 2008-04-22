<%
use Octopussy;

my $pid_dir = Octopussy::Directory("running");
my $pid_param = $Session->{extracted};
my $pid_file = $pid_dir . "octo_extractor_${pid_param}.pid";
my $status_file = $pid_dir . "octo_extractor_${pid_param}.status";
my $status = "";
my ($desc, $current, $total, $match) = ("", 0, 0, 0);

if (-f $pid_file)
{
	my $pid = `cat "$pid_file"`;
	kill USR1 => $pid;
}
if (-f $status_file)
{
	open(FILE, "cat \"$status_file\" |");
	$status = <FILE>;
	close(FILE);
	($desc, $current, $total, $match) = ($1, $2, $3, $4)
		if ($status =~ /(.+)\[(\d+)\/(\d+)\] \[(\d+)\]$/);
}
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<desc><%= $desc %></desc>
	<current><%= $current %></current>
	<total><%= $total %></total>
	<match><%= $match %></match>
</root>
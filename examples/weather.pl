use 5.010;
use Acme::UseStrict;
use Acme::What;
use Web::Magic;

sub WHAT
{
	'use strict';
	my @args = $_[0] =~ m{\w+}g;
	
	my $woeid = pop @args;
	$woeid = do
		{
			warn "If you want to know the weather $woeid, "
				. "define the YAHOO_WOEID environment variable. "
				. "Assuming you live where TOBYINK lives"
				unless exists $ENV{YAHOO_WOEID}
				    && defined $ENV{YAHOO_WOEID};
			($ENV{YAHOO_WOEID} // 26191)
		}
		if $woeid =~ m{^(outside|here)$}i;
	
	my $unit = $^F==1 ? 'F' : 'C';
	# if $^F == 2 then detect unit by locale. Belize and US use Fahrenheit.
	if ($^F > 1 and $ENV{LC_MEASUREMENT} =~ /^.._(US|BZ)/i)
	{
		$unit = 'F';
	}
	
	my %opts = (
		'w'  => $woeid, 
		'u'  => lc $unit,
		);
	
	my ($temperature) = Web::Magic
		-> new(q<http://weather.yahooapis.com/forecastrss>, %opts)
		-> findnodes('//yweather:condition/@temp')
		-> map(sub { $_->value });	
	
	return "$temperature $unit";
}

local $^F = 1;
my $temperature=what? (i mean outside);
say "The temperature is $temperature";

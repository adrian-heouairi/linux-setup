use strict;
use warnings;

my $website = "mojim.com";

scalar {
    site => "$website",
    code => sub {
        my ($content) = @_;

        if ($content =~ m{<dd id='fsZx3' class='fsZx3'><br />(.+)<br />}) {
            my $lyrics = $1;
            $lyrics =~ s{<br />}{\n}g;
            $lyrics =~ s/.*mojim\.com.*\n//;
            $lyrics = "$website\n$lyrics";
            if (length($lyrics) <= 50) { $lyrics = "$lyrics ==================================================" };
            return $lyrics;
        }

        if (-e "/tmp/cl") {
            return "<!-- $website: didn't match regex ================================================== -->\n$content";
        }
    }
}

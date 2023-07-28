use strict;
use warnings;

my $website = "uta-net.com";

scalar {
    site => "$website",
    code => sub {
        my ($content) = @_;

        if ($content =~ m{<div id="kashi_area" itemprop="text">(.+)</div>}) {
            my $lyrics = $1;
            $lyrics =~ s{<br />}{\n}g;
            $lyrics = "$website\n$lyrics";
            if (length($lyrics) <= 50) { $lyrics = "$lyrics ==================================================" };
            return $lyrics;
        }

        if (-e "/tmp/cl") {
            return "<!-- $website: didn't match regex ================================================== -->\n$content";
        }
    }
}

use strict;
use warnings;

my $website = "kkbox.com";

scalar {
    site => "$website",
    code => sub {
        my ($content) = @_;

        if ($content =~ m{<div class="lyrics">.*?<p><br />\n(.*?)</p>}s) {
            my $lyrics = $1;
            $lyrics =~ s{<br />}{}g;
            #$lyrics =~ s/.*mojim\.com.*\n//;
            $lyrics = "$website\n$lyrics";
            if (length($lyrics) <= 50) { $lyrics = "$lyrics ==================================================" };
            return $lyrics;
        }

        if (-e "/tmp/cl") {
            return "<!-- $website: didn't match regex ================================================== -->\n$content";
        }
    }
}

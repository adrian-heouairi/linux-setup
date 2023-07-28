use strict;
use warnings;

my $website = "utaten.com";

scalar {
    site => "$website",
    code => sub {
        my ($content) = @_;

        if ($content =~ m{<div class="hiragana" >\n(.*?)</div>}s) {
            my $lyrics = $1;
            $lyrics =~ s{<span class="ruby"><span class="rb">}{}g;
            $lyrics =~ s{</span><span class="rt">.*?</span></span>}{}g;
            $lyrics =~ s{^ +}{}g;
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

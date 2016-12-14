#!/usr/bin/env perl6

my $spotify-pid =  q:x/ps xf | grep "spotify" | head -n 1 | awk '{print $1}'/.trim;
my $window-titles = q:x/wmctrl -lp/;

my $pid-and-title-regex = /\S+ \s+ \d+ \s+ $<pid> = [\d*] \s+ \S+ \s+ $<title> = [.*]/;

sub get-spotify-title {

	my @spotify-titles = gather for $window-titles.lines {
		given $_ {
			when $pid-and-title-regex and $<pid> == $spotify-pid {
				take $<title>.Str;
			}
		}
	}

	if @spotify-titles.elems == 0 {
		"spotify not running!"
	} else {
		@spotify-titles[0];
	}

}

sub update-spotify-title($file-name, $song-title) {

	my $data = do if $file-name.IO.e {
		slurp $file-name;
	} else {
		"";
	}

	if $data !eq $song-title {
		spurt $file-name, "Now Playing: $song-title";
		say "INFO: title changed from file contents, writing!"
	}

}

sub MAIN($output-file-path) {
	my $spotify-title = get-spotify-title;
	update-spotify-title $output-file-path, $spotify-title;
}

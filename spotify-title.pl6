#!/usr/bin/env perl6

# The MIT License (MIT)
#
# Copyright (c) 2016 Robin Hübner <profan@prfn.se>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

my $pid-and-title-regex = /\S+ \s+ \d+ \s+ $<pid> = [\d*] \s+ \S+ \s+ $<title> = [.*]/;

sub get-spotify-title {

	my $spotify-pid =  q:x/ps xf | grep "spotify" | head -n 1 | awk '{print $1}'/.trim;
	my $window-titles = q:x/wmctrl -lp/;

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
		spurt $file-name, $song-title;
		say "INFO: title changed from file contents, writing!"
	}

}

sub MAIN(Str $output-file-path, Bool :$loop = False, Int :$interval-seconds = 5) {

	if $loop {
		say "INFO: running spotify-title at a $interval-seconds second interval.";
		while $loop {
			my $spotify-title = get-spotify-title;
			update-spotify-title $output-file-path, $spotify-title;
			sleep $interval-seconds;
		}
	} else {
		my $spotify-title = get-spotify-title;
		update-spotify-title $output-file-path, $spotify-title;
	}

}

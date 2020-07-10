#!/usr/local/bin/perl

use strict;
use warnings;
use Term::ANSIColor;
use File::Copy;

sub get_repos_index {
	my $user = $_[0];
	my $home_dir = '/usr/home/' . $user . '/';
	opendir(DIR, $home_dir);
	my @repos;
	my $i = 0;
	while (my $dir = readdir(DIR)) {
		next if ($dir =~ m/^\./);
		next if (!(-e $home_dir . $dir . '/git-daemon-export-ok'));
		$repos[$i] = $dir;
		$i += 1;
	}
	closedir(DIR);
	my @sorted_repos = sort @repos;
	return @sorted_repos;
}

sub stagit_generate {
	my ($user, @repos) = @_;
	my $site_dir = '/usr/local/www/gitjoe/';
	my $home_dir = '/usr/home/' . $user . '/';
	chdir($site_dir);
	system(
		'/usr/local/bin/dash',
		'-c',
		'/bin/rm -rf ' . $user . '/'
		);
	mkdir($user . '/', 0755);
	my $i = 0;
	my $repos_line = "";
	copy('./css/gitjoe.css', './' . $user . '/style.css');
	copy('./img/logo.png', './' . $user . '/logo.png');
	while ($i < @repos) {
		chdir($site_dir . $user . '/');
		$repos_line = $repos_line . ' ' . $home_dir . $repos[$i] . '/';
		substr($repos[$i], -4) = "";
		mkdir($repos[$i] . '/', 0755);
		chdir($site_dir . $user . '/' . $repos[$i] . '/');
		$repos[$i] = $repos[$i] . '.git';
		print "Indexing " . colored($user . '/' . $repos[$i], 'bold') . ".\n";
		system(
			'/usr/local/bin/dash',
			'-c',
			'/usr/local/bin/stagit ' . $home_dir . $repos[$i] . '/'
			);
		copy('../style.css', './style.css');
		copy('../logo.png', './logo.png');
		$i += 1;
	}
	chdir($site_dir . $user . '/');
	system(
		'/usr/local/bin/dash',
		'-c',
		'/usr/local/bin/stagit-index ' . $repos_line . '> index.html'
		);
	system(
		'/usr/local/bin/dash',
		'-c',
		"/usr/bin/sed 's/<td>" . $user . "<\\/td>/<td class=\"td_author\">" . $user . "<\\/td>/g' index.html >sedded_index.html"
		);
	system(
		'/usr/local/bin/dash',
		'-c',
		"/usr/bin/sed 's/<td><span class=\"desc\">Repositories<\\/span><\\/td>/<td><span class=\"desc\"><h1>" . $user . " - Repositories<\\/h1><\\/span><\\/td><\\/tr><tr><td><\\/td><td>Back to <a href=\"https:\\/\\/git.jozanleclerc.xyz\\/\">GitJoe<\\/a><\\/td><\\/tr>/' sedded_index.html >re_sedded_index.html"
		);
	unlink('./sedded_index.html');
	system(
		'/usr/local/bin/dash',
		'-c',
		"/usr/bin/sed 's/log.html/files.html/g' re_sedded_index.html >index.html"
		);
	unlink('./re_sedded_index.html');
	return;
}

sub main {
	my $home_dir = '/usr/home/';
	my @users;
	opendir(DIR, $home_dir);
	my $i = 0;
	while (my $dir = readdir(DIR)) {
		next if ($dir eq 'git-ro');
		next if ($dir =~ m/^\./);
		$users[$i] = $dir;
		$i += 1;
	}
	closedir(DIR);
	$i = 0;
	while ($i < @users) {
		my @repos = get_repos_index($users[$i]);
		stagit_generate($users[$i], @repos);
		$i += 1;
	}
	print "Updated GitJoe index.\n";
	exit;
}

main();

__END__

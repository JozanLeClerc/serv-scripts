#!/usr/local/bin/perl

use strict;
use warnings;
use Term::ANSIColor;

sub get_repos_index {
	my $user = $_[0];
	my $homedir = '/usr/home/' . $user . '/';
	opendir(DIR, $homedir);
	my @repos;
	my $i = 0;
	while (my $dir = readdir(DIR)) {
		next if ($dir =~ m/^\./);
		next if (!(-e $homedir . $dir . '/git-daemon-export-ok'));
		$repos[$i] = $dir;
		$i += 1;
	}
	$i = 0;
	print 'User: ' . colored($user, 'bold') . " repos: \n";
	while ($i < @repos) {
		print $repos[$i] . "\n";
		$i += 1;
	}
	closedir(DIR);
	print "\n";
	return @repos;
}

sub stagit_generate {
	my $user = $_[0];
	my @repos = $_[1];
	my $i = 0;
	while ($i < @repos) {
		print $repos[$i];
		$i += 1;
	}
	return;
}

sub main {
	my $homedir = '/usr/home/';
	my @users;
	opendir(DIR, $homedir);
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
	exit;
}

main();

__END__
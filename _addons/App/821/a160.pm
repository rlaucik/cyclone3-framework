#!/bin/perl
package App::821::a160;

=head1 NAME

App::401::a160

=cut
use open ':utf8', ':std';
use if $] < 5.018, 'encoding','utf8';
use utf8;
use strict;

BEGIN {eval{main::_log("<={LIB} ".__PACKAGE__);};}

=head1 DESCRIPTION

a160 enhancement to a821

=cut

=head1 DEPENDS

=over

=item *

L<App::821::_init|app/"821/_init.pm">

=item *

L<App::020::_init|app/"020/_init.pm">

=item *

L<App::020::a160|app/"020/a160.pm">

=back

=cut

use App::821::_init;
use App::020::_init;
use App::020::a160;

our $VERSION='1';

sub get_relation_iteminfo
{
	shift;
	my %env=@_;
	my $t=track TOM::Debug(__PACKAGE__."::get_relation_iteminfo()");
	
	foreach (sort keys %env) {main::_log("input '$_'='$env{$_}'") if defined $env{$_}};
	
	# if db_name is undefined, use local name
	$env{'r_db_name'}=$App::821::db_name unless $env{'r_db_name'};
	
	my $lng_in;
	
	if ($env{'lng'})
	{
		$lng_in="AND lng='".$env{'lng'}."'";
	}
	
	my %info;
	
	if ($env{'r_table'} eq "discussion")
	{
		my $sql=qq{
			SELECT
				ID,
				name,
				ID_forum,
				lng
			FROM
				`$env{'r_db_name'}`.a821_discussion
			WHERE
				ID_entity=$env{'r_ID_entity'}
				$lng_in
			LIMIT 1
		};
		my %sth0=TOM::Database::SQL::execute($sql,'db_h'=>'main');
		if (my %db0_line=$sth0{'sth'}->fetchhash())
		{
			$info{'name'}=$db0_line{'name'};
			$info{'ID'}=$db0_line{'ID'};
			$info{'ID_forum'}=$db0_line{'ID_forum'};
			$info{'ID_category'}=$db0_line{'ID_forum'};
			$info{'lng'}=$db0_line{'lng'};
			main::_log("returning name='$info{'name'}'");
			$t->close();
			return %info;
		}
	}
	
	if ($env{'r_table'} eq "discussion_forum")
	{
		my $sql=qq{
			SELECT
				ID,
				name,
				lng
			FROM
				`$env{'r_db_name'}`.a821_discussion_forum
			WHERE
				ID_entity=$env{'r_ID_entity'}
				$lng_in
			LIMIT 1
		};
		my %sth0=TOM::Database::SQL::execute($sql,'db_h'=>'main');
		if (my %db0_line=$sth0{'sth'}->fetchhash())
		{
			$info{'name'}=$db0_line{'name'};
			$info{'ID'}=$db0_line{'ID'};
			$info{'lng'}=$db0_line{'lng'};
			main::_log("returning name='$info{'name'}'");
			$t->close();
			return %info;
		}
	}
	
	$t->close();
	return undef;
}



1;
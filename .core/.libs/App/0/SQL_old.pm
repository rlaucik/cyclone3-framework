#!/bin/perl
package App::0::SQL_old;
#use App::0::SQL::functions;
use strict;

BEGIN {eval{main::_log("<={LIB} ".__PACKAGE__);};}

sub allocate
{
 my $class=shift;
 my %env=@_;
 my $self={};
  
 die "can't allocate() - need DBH" unless $env{DBH};
 die "can't allocate() - need db" unless $env{db};
  
 %{$self->{env}}=%env;
 $self->{DBH}=$env{DBH};
 $self->{db}=$env{db};

 $self->{limit}=1 unless $self->{limit}=($env{select_limit}=~/^(\d+|\d+,\d+)$/)[0]; # urcim limit
 $self->{s_limit}="LIMIT ".$self->{limit};# urcim vyzor limitu do QUERY
 $self->{limit}=~/^(\d+)$/ || $self->{limit}=~/^(\d+),(\d+)$/; # urcim si rozsahy
 $self->{limit_from}=$1 if $2; # from
 $self->{limit_max}=$2 || $1; # maximalny pocet na vyselectovanie
 
 return bless $self,$class;
}


# MUSI BYT SUCASTOU OBJECTU KUA!!!!! (nedavaj to von!)
# kvoli errstr
sub _execute
{
 my $self=shift;
 my $pointer;
 return undef unless my $query=shift;
 
 eval
 {
  local *STDERR;open(STDERR,">>/dev/null") || die "Cant redirect STDERR: $!\n";  
  $pointer=$self->{DBH}->Query($query) || die "SQL ERROR >>".$query."<< :".$self->{DBH}->errstr();
 };  
 return undef if $self->{errstr}=$@;  
 
 return $pointer;
}



sub execute
{
 my $self=shift;  
 my $pointer="db0";  
 my $time_duration=(Time::HiRes::gettimeofday)[0]+((Time::HiRes::gettimeofday)[1]/1000000);
 
 
 $self->{Query}=do
 {
  ($self->{select_arch}) ? $self->{Query_arch}: 
  ($self->{select_union}) ? $self->{Query_union}: 
  $self->{Query}
 };
 
 $self->{Query_log}.=$self->{Query}."\n\n"; # pridame do query logu co som robil
 return undef unless $self->{db0}=$self->_execute($self->{Query}); 
 $self->{rows_}=$self->{db0}->NumRows();
 $self->{rows}+=$self->{rows_};
  
 if ($self->{rows_}<$self->{limit_max}) # ak pocet vyselectovanych riadkov je menej nez pozadujem
 {
  if ($self->{select_arch})
  {
   $self->{limit_arch}=$self->{limit_max}-$self->{rows};
   $self->{select_arch_}=1; # pre to aby som vedel ze mam parsovat aj z druheho pointeru vo fetchhash a fetchrow
   $pointer="db1";
   $self->{limit_skipped}=0;
   
   if ($self->{limit_from}){$self->subquery_initialize();} # inicializacia podquery
   
   if (($self->{_subquery})&&($self->{_subquery}->execute())&&(my %db0_line=$self->{_subquery}->fetchrow()))
   {
    $self->{Query_log}.=$self->{_subquery}{Query_log}."\n\n"; # pridame do query logu co som robil    
    $self->{limit_skipped}=$db0_line{COUNT_ORIGIN};
    if ($self->{limit_skipped}<$self->{limit_from})
    {
     $self->{limit_arch}=($self->{limit_from}-$self->{limit_skipped}).",".$self->{limit_arch};
    }
   }   
   
   $self->{Query_arch}.="LIMIT ".$self->{limit_arch};
   $self->{Query_log}.=$self->{Query_arch}."\n\n"; # pridame do query logu co som robil    
   return undef unless $self->{db1}=$self->_execute($self->{Query_arch});
   $self->{rows_}=$self->{$pointer}->NumRows();   
   $self->{rows}+=$self->{rows_};   
  }
  elsif ($self->{select_union_allow})
  {
   $self->{Query_log}.=$self->{Query_union}."\n\n"; # pridame do query logu co som robil    
   return undef unless $self->{db0}=$self->_execute($self->{Query_union}); 
   $self->{rows_}=$self->{db0}->NumRows();  
   $self->{rows}=$self->{rows_};
  }
 } 
  
 $self->{Query_duration}=(Time::HiRes::gettimeofday)[0]+((Time::HiRes::gettimeofday)[1]/1000000)-$time_duration; 
 return 1;
}




sub fetchhash
{
 my $self=shift;
 die "object not defined" unless $self;
  
 undef $self->{Query_hash};
 delete $self->{Query_hash};
 
 loopfetch:
 if ($self->{select_arch_})
 {
  %{$self->{Query_hash}}=$self->{db0}->fetchhash() or %{$self->{Query_hash}}=$self->{db1}->fetchhash();
 }
 else
 {
  %{$self->{Query_hash}}=$self->{db0}->fetchhash();
 }
  
 if ($self->{Query_hash}{link} && $self->{env}{link})
 {
  goto loopfetch unless %{$self->{Query_hash}}=$self->get_link(link=>$self->{Query_hash}{link},exclude=>$self->{Query_hash}{ID});
 }
  
 return %{$self->{Query_hash}};
}




sub errstr
{
 my $self=shift; 
 return $self->{errstr};
}




sub rows
{
 my $self=shift; 
 return $self->{rows};
}





1;

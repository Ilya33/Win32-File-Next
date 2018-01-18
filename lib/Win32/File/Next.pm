# Win32::File::Next - Copyright (C) 2018 Ilya Pavlov
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

package Win32::File::Next;

use strict;
use warnings;

use Carp qw( croak );
use File::Spec;
use File::Spec::Functions;

#use utf8;

use Data::Dumper;

use Win32::LongPath;

$Win32::File::Next::VERSION = "0.001000";

our $name; # name of the current file
our $dir;  # dir of the current file

my %skip_dirs = (
    File::Spec->curdir => undef,
    File::Spec->updir => undef
);
my %default_params = (
    file_filter     => undef,
    descend_filter  => undef,
    error_handler   => sub { CORE::die $_[0] },
    warning_handler => sub { CORE::warn @_ }
);



#TODO add get disks API



sub files {
    #croak if $_[0] eq __PACKAGE__

    my $params = {%default_params, (ref($_[0]) eq 'HASH' ?%{+shift} :())};

    my @queue;

    for(@_) {
        if(testL('d', $_)) {
            push @queue, ($_, undef, $_);
        }
        else {
            push @queue, (undef, $_, $_);
        }
    }

    return sub { # iterator
        while(@queue) {
            my ($dir, $file, $fullpath) = splice(@queue, 0, 3);

            if(testL('f', $fullpath)) {
                return wantarray ?($dir, $file, $fullpath) :$fullpath;
            }

            if(testL('d', $fullpath)) {
                my $dir_obj = Win32::LongPath->new();
                $dir_obj->opendirL($fullpath);

                unshift @queue, map { (
                    $fullpath,
                    $_,
                    $fullpath.'/'.$_
                ) } grep {$_ !~ /^\.\.?$/} $dir_obj->readdirL();

                $dir_obj->closedirL();
            }
        }

        return;
    };
}



1;



__END__

=encoding utf-8

=head1 NAME

Win32::File::Next - It's new $module

=head1 SYNOPSIS

    use Win32::File::Next;

=head1 DESCRIPTION

Win32::File::Next is ...

=head1 LICENSE

Copyright (C) Ilya Pavlov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ilya Pavlov E<lt>ilux@cpan.orgE<gt>

=cut
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
    descend_filter  => undef,
    error_handler   => sub { CORE::die $_[0] },
    warning_handler => sub { CORE::warn @_ }
);



#TODO add get disks API



sub files {
    croak "Wrong usage" if defined($_[0]) && $_[0] eq __PACKAGE__;

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

            if(testL('f', $fullpath)) { #if bad FS?
                return wantarray ?($dir, $file, $fullpath) :$fullpath;
            }

            if(testL('d', $fullpath)) {
                my $dir_obj = Win32::LongPath->new();

                if(!$dir_obj->opendirL($fullpath)) {
                    $params->{error_handler}->( "$fullpath: $!", $! +0 );
                    next;
                }

                for my $item ( grep { !exists $skip_dirs{$_} } $dir_obj->readdirL() ) {
                    if(defined $params->{descend_filter}) {
                        local $Win32::File::Next::dir = $fullpath.'/'.$item;
                        local $_ = $item;
                        next if not $params->{descend_filter}->();
                    }

                    unshift @queue, ($fullpath, $item, $fullpath.'/'.$item);
                }

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

Win32::File::Next - File-finding iterator for Windows

=head1 SYNOPSIS

    use Win32::File::Next;

=head1 DESCRIPTION

Win32::File::Next is ...

=head1 SEE ALSO

L<File::Next>

=head1 AUTHOR

Ilya Pavlov E<lt>ilux@cpan.orgE<gt>

=head1 LICENSE

Copyright (C) Ilya Pavlov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Centuran Consulting, https://centuran.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

#
# WARNING: This file is autogenerated from "scripts/auto_build/spec/templates" via
# "bin/otrs.Console.pl Dev::Tools::RPMSpecGenerate". All changes will be lost.
#

Summary:      OTRS Help Desk.
Name:         otrs
Version:      0.0
Copyright:    GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
Group:        Applications/Mail
Provides:     otrs
Requires:     bash-completion cronie apache2 apache2-mod_perl perl perl(Archive::Zip) perl(Date::Format) perl(DateTime) perl(DBI) perl(Encode::HanExtra) perl(IO::Socket::SSL) perl(JSON::XS) perl(LWP::UserAgent) perl(Net::DNS) perl(Net::LDAP) perl(Template) perl(Text::CSV) perl(Text::CSV_XS) perl(URI) perl(XML::LibXML) perl(XML::LibXSLT) perl(XML::Parser) perl(YAML::XS) procmail
AutoReqProv:  no
Release:      01
Source0:      otrs-%{version}.tar.bz2
BuildArch:    noarch
BuildRoot:    %{_tmppath}/%{name}-%{version}-build

%description
OTRS is an Open source Ticket Request System with many features to manage
customer telephone calls and e-mails. It is distributed under the GNU
General Public License (GPL) and tested on Linux and Mac OS. Do you
receive many e-mails and want to answer them with a team of agents?
You're going to love OTRS!

SuSE series: ap

%prep
%setup

%build
# copy config file
cp Kernel/Config.pm.dist Kernel/Config.pm
# rename config POD file
mv Kernel/Config.pod.dist Kernel/Config.pod
# copy all crontab dist files
for foo in var/cron/*.dist; do mv $foo var/cron/`basename $foo .dist`; done
# copy all .dist files
cp .procmailrc.dist .procmailrc
cp .fetchmailrc.dist .fetchmailrc
cp .mailfilter.dist .mailfilter

%install
# delete old RPM_BUILD_ROOT
rm -rf $RPM_BUILD_ROOT
# set DESTROOT
export DESTROOT="/opt/otrs/"
# create RPM_BUILD_ROOT DESTROOT
mkdir -p $RPM_BUILD_ROOT/$DESTROOT/
# copy files
cp -R . $RPM_BUILD_ROOT/$DESTROOT
# configure apache
install -d -m 755 $RPM_BUILD_ROOT/etc/apache2/conf.d
install -m 644 scripts/apache2-httpd.include.conf $RPM_BUILD_ROOT/etc/apache2/conf.d/zzz_otrs.conf

# set permission
export OTRSUSER=otrs
useradd $OTRSUSER || :
useradd wwwrun || :
groupadd www || :
$RPM_BUILD_ROOT/opt/otrs/bin/otrs.SetPermissions.pl --web-group=www

%pre
# useradd
export OTRSUSER=otrs
echo -n "Check OTRS user ... "
if id $OTRSUSER >/dev/null 2>&1; then
    echo "$OTRSUSER exists."
    # update groups
    usermod -g www $OTRSUSER
    # update home dir
    usermod -d /opt/otrs $OTRSUSER
else
    useradd $OTRSUSER -d /opt/otrs/ -s /bin/bash -g www -c 'OTRS System User' && echo "$OTRSUSER added."
fi
echo "Enable apache module mod_perl..."
a2enmod perl
echo "Enable apache module mod_version..."
a2enmod version
echo "Enable apache module mod_deflate..."
a2enmod deflate
echo "Enable apache module mod_filter..."
a2enmod filter
echo "Enable apache module mod_headers..."
a2enmod headers

%post
export OTRSUSER=otrs

# note
HOST=`hostname -f`
echo ""
echo "Next steps: "
echo ""
echo "[restart web server]"
echo " systemctl restart apache2.service"
echo ""
echo "[install the OTRS database]"
echo " Make sure your database server is running."
echo " Use a web browser and open this link:"
echo " http://$HOST/otrs/installer.pl"
echo ""
echo "[start OTRS daemon and corresponding watchdog cronjob]"
echo " /opt/otrs/bin/otrs.Daemon.pl start"
echo " /opt/otrs/bin/Cron.sh start"
echo ""
echo "((enjoy))"
echo " Your OTRS Team"
echo ""

%clean
rm -rf $RPM_BUILD_ROOT

%files
%config /etc/apache2/conf.d/zzz_otrs.conf

%config(noreplace) /opt/otrs/Kernel/Config.pm
%config(noreplace) /opt/otrs/.procmailrc
%config(noreplace) /opt/otrs/.fetchmailrc
%config(noreplace) /opt/otrs/.mailfilter

%dir /opt/otrs/
/opt/otrs/RELEASE
/opt/otrs/ARCHIVE
/opt/otrs/.bash_completion
/opt/otrs/.procmailrc.dist
/opt/otrs/.fetchmailrc.dist
/opt/otrs/.mailfilter.dist

%dir /opt/otrs/Custom/
/opt/otrs/Custom/README

%dir /opt/otrs/Kernel/

%dir /opt/otrs/Kernel/Config/
/opt/otrs/Kernel/Config.pm.dist
/opt/otrs/Kernel/Config.pod
/opt/otrs/Kernel/Config/Files/
/opt/otrs/Kernel/Config/Defaults.pm

/opt/otrs/Kernel/GenericInterface*

/opt/otrs/Kernel/Language.pm
%dir /opt/otrs/Kernel/Language/
/opt/otrs/Kernel/Language/*.pm

/opt/otrs/bin*
/opt/otrs/Kernel/Autoload*
/opt/otrs/Kernel/Modules*
/opt/otrs/Kernel/Output*
/opt/otrs/Kernel/System*
/opt/otrs/scripts*
/opt/otrs/i18n/otrs/*

%dir /opt/otrs/var/
%dir /opt/otrs/var/article/
/opt/otrs/var/fonts/
/opt/otrs/var/httpd/
/opt/otrs/var/logo-otrs.png
%dir /opt/otrs/var/cron/
%dir /opt/otrs/var/log/
%dir /opt/otrs/var/sessions/
%dir /opt/otrs/var/spool/
/opt/otrs/var/cron/*
%dir /opt/otrs/var/tmp/
%dir /opt/otrs/var/stats/
/opt/otrs/var/stats/*.xml
%dir /opt/otrs/var/processes/examples/
/opt/otrs/var/processes/examples/*
%dir /opt/otrs/var/webservices/examples/
/opt/otrs/var/webservices/examples/*.pm

/opt/otrs/Kernel/cpan-lib*

%doc /opt/otrs/*.md
%doc /opt/otrs/COPYING
%doc /opt/otrs/COPYING-Third-Party
%doc /opt/otrs/doc*

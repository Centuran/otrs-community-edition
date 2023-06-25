stop_service() {
    local SERVICE=$1

    systemctl stop "${SERVICE}"
}

start_service() {
    local SERVICE=$1

    systemctl start "${SERVICE}"
}

restart_service() {
    local SERVICE=$1

    systemctl restart "${SERVICE}"
}

get_webserver_group() {
    if [ -e /etc/redhat-release ]; then
        echo 'apache'
    elif [ -e /etc/debian_version ]; then
        echo 'www-data'
    fi
}

get_webserver_service() {
    if [ -e /etc/redhat-release ]; then
        echo 'httpd'
    elif [ -e /etc/debian_version ]; then
        echo 'apache2'
    fi
}

run_as_otrs_user() {
    setpriv --euid $(id -u otrs) --ruid $(id -u otrs) \
        --egid $(id -g $(get_webserver_group)) \
        --rgid $(id -g $(get_webserver_group)) \
        --keep-groups \
        "$@"
}

fix_cron_files_owner() {
    chown otrs $(ls /opt/otrs/var/cron/* | \
        grep -Ev '(\.(dist|rpm|bak|backup|custom_backup|save|swp)|\~)$')
}

stop_background_jobs() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->StopBackgroundTasks();
        '
}

start_background_jobs() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->StartBackgroundTasks();
        '
}

shell_stop_background_jobs() {
    local INSTALL_DIR=$1

    if crontab -l -u otrs &>/dev/null; then
        "${INSTALL_DIR}/bin/Cron.sh" stop otrs >/dev/null 2>&1
    fi

    run_as_otrs_user "${INSTALL_DIR}/bin/otrs.Daemon.pl" stop >/dev/null 2>&1

    return $?
}

shell_start_background_jobs() {
    local INSTALL_DIR=$1

    "${INSTALL_DIR}/bin/Cron.sh" start otrs >/dev/null 2>&1

    run_as_otrs_user "${INSTALL_DIR}/bin/otrs.Daemon.pl" start >/dev/null 2>&1

    return $?
}

stop_user_sessions() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->StopUserSessions();
        '
    
    return $?
}

enable_maintenance_mode() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2
    local NEW_VERSION=$3

    local MAINT_ID=$(
        perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
            -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
            -MKernel::System::ObjectManager \
            -e '
                use strict;
                use warnings;

                local $Kernel::OM = Kernel::System::ObjectManager->new();

                my $Version = shift;

                my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

                my $MaintID = $UpdateObject->EnableMaintenanceMode(
                    DistVersion => $Version,
                );

                print "$MaintID\n";
            ' \
            "${NEW_VERSION}"
    )

    echo $MAINT_ID
}

disable_maintenance_mode() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2
    local MAINT_ID=$3

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();

            my $MaintID = shift;

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->DisableMaintenanceMode(
                SystemMaintenanceID => $MaintID,
            );
        ' \
        "${MAINT_ID}"
}

update_db() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();
            
            my $DistPath = shift;

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->UpdateDatabase(
                DistPath => $DistPath,
            );
        ' \
        "${FILES_DIR}"
    
    return $?
}

update_files() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();
            
            my $DistPath = shift;

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->CopyFiles(
                DistPath => $DistPath,
            );
        ' \
        "${FILES_DIR}"

    return $?
}

reset_config_and_cache() {
    local FILES_DIR=$1
    local INSTALL_DIR=$2

    perl -I"${FILES_DIR}" -I"${FILES_DIR}/Kernel/cpan-lib" \
        -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();

            my $UpdateObject = $Kernel::OM->Get("Kernel::System::Update");

            $UpdateObject->ResetConfigAndCache();
        '

    return $?
}

remove_unneeded_files() {
    local INSTALL_DIR=$1

    if [ -d "${INSTALL_DIR}/scripts/test" ]; then
        rm -r "${INSTALL_DIR}/scripts/test"
    fi

    return 0
}

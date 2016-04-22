#!/bin/bash

# Address
to_address=$to_address" ""x-tomomitsuh@jp.sony.com"
#to_address=$to_address" ""Takashi.Kudo@jp.sony.com"
#to_address=$to_address" ""Kouichi.Ideno@jp.sony.com"

# Input
select_branch=$1
if [ "$select_branch" == "master" ]; then
    dir=master
    repo=origin/master
    repo_=origin/release/bdre12g/gm1.8
    root=$P4PATH_12G_BASELINE
elif [ "$select_branch" == "gm1.8" ]; then
    dir=release_gm1.8
    repo=origin/release/bdre12g/gm1.8
    repo_=origin/master
    root=$P4PATH_12G_MP
else
    CMDNAME=`basename $0`
    echo "Usage: ./$CMDNAME branch"
    echo "       branch: master | gm1.8"
    echo "Exit."
    exit
fi
if [ "$root" == "" ]; then
    echo "Please set the P4 environment variable [ P4PATH_12G_BASELINE or P4PATH_12G_MP ]."
    echo "ex) export P4PATH_12G_BASELINE=~/UNI-SYSTEM-RE/BASELINE/"
    echo "Exit."
    exit
fi
echo "Select [$repo] to [$root]"


# Check p4 opened
echo "p4 pre-check"
p4 opened > tmp_check_p4
if [ -s ./tmp_check_p4 ]; then
    echo "Error! There is the file which is in an open state."
    cat ./tmp_check_p4
    echo "Exit."
    exit
fi
rm -rf tmp_check_p4

# p4 sync
echo "p4 sync"
p4 sync $root/WebBrowser/...

echo
echo Start Step1
echo

# Check Last Commit
if [ -e $root/WebBrowser/WebApp/LAST_COMMIT ]; then
    last_rev=$(head -n1 $root/WebBrowser/WebApp/LAST_COMMIT | awk '{ print $3; }')
else
    read -p "Last Commit? -> " last_rev
    if [ "$last_rev" == "" ]; then
        last_rev=$repo_
    fi
fi
echo "Last Commit: $last_rev"

# Export
export_dir=export/$dir
rm -rf $export_dir
mkdir $export_dir
#git archive --worktree-attributes --format=tar $repo app LAST_COMMIT | tar -C $export_dir/ -xf -
git archive --worktree-attributes --format=tar $repo app LAST_COMMIT > $export_dir/app.tar
echo Finish archive! export to \"$export_dir\"

# Change Info
change_info_file=$export_dir/change_info_git.txt
echo ----- change log ----- | tee $change_info_file
git log --grep "Merge pull request" --pretty=format:'commit: %h %x0A%ci %x0A  %s%x0A  %b%-' $last_rev..$repo | tee -a $change_info_file
echo | tee -a $change_info_file
echo ----- change files ----- | tee -a $change_info_file
git diff --name-status $last_rev...$repo | tee -a $change_info_file

echo
echo Start Step2
echo

# Check tar file
if [ ! -e $export_dir/app.tar ]; then
    echo "There is no $export_dir/app.tar"
    echo "Exit."
    exit
fi

webapp_path=$root/WebBrowser/WebApp

# Function make rootfs-list
make_fslist() {
    tmp_file=$webapp_path/tmp_fslist.txt
    rm -rf $tmp_file
    find $webapp_path/app > $tmp_file
    sed -i -e 's/\/home.*\/WebApp\/app/\.\/etc\/www\/app/' $tmp_file
    echo "Create fslist -> $tmp_file"
    p4 edit $root/Tools/Target/rootfs-list.txt
}

# Merge
rm -rf $webapp_path/app
tar -C $webapp_path/ -xf $export_dir/app.tar

echo "Start Add and Edit and Revert"
# find $webapp_path/app | xargs p4 add
p4 add $webapp_path/app/... > /dev/null 2>&1
p4 edit $webapp_path/app/... > /dev/null 2>&1
p4 revert -a $webapp_path/app/... > /dev/null 2>&1
echo "===== P4 Opened List ====="
p4 opened | tee $export_dir/change_info_p4.txt
p4 opened | grep "add default change"
if [ $? == 0 ]; then
    echo
    echo !!!!! There is an additional file!!!!!
    make_fslist
fi

# LAST_COMMIT
echo "Update LAST_COMMIT"
if [ -e $webapp_path/LAST_COMMIT ]; then
    p4 edit $webapp_path/LAST_COMMIT
fi

echo
echo Start Step3
echo

# Submit
echo "Check Opened!"
p4 opened
echo "Submit!!!"
##### p4 submit -d "[BDRE12G][R12GTD-2309] Merged from term git"
p4 changes -m1 > $export_dir/submit_info.txt

# Backup
backup_dir_base=../merge_backup; [ ! -e $backup_dir_base ] && mkdir -p $backup_dir_base
backup_dir=$dir$(date "+_%Y%m%d_%H%M_%S")
cp -rf $export_dir $backup_dir_base/$backup_dir
rm -rf $backup_dir_base/$backup_dir/app.tar
echo "Backup to $backup_dir_base/$backup_dir"

echo
echo Start Step4
echo

# Subject
changelist="_CL"$(awk '{print $2;}' $export_dir/submit_info.txt)
date=$(date "+%Y%m%d_%H%M")
branch="@"$dir
subject="[BDRE12G][WebApp Merge] Finish Merge GitHub to P4 : $date$changelist$branch"

# Body
change_info_git=$(cat $export_dir/change_info_git.txt)
body="Hi All\n\n"
body="${body}Finish Merge GitHub to P4\n\n"
body="${body}${change_info_git}"
body="${body}\n\nBest Regards"

# Attachments
tmp_git=$export_dir/change_info_git.txt
tmp_p4=$export_dir/change_info_p4.txt

# Send Mail
echo "Send Mail"
echo "To      : $to_address"
echo "Subject : $subject"
echo "Body    :"
# echo -e "$body"
##### echo -e "$body" | mutt -s "$subject" -a ${tmp_git} -a ${tmp_p4} -- $to_address

echo Finish

#!/bin/bash

name=$1
storage=/var/www/laboratory
dir=/var/www/cicd
now=$(bash $dir/pcal.sh -t | tr "-" "/")
lab="lab-$RANDOM"

echo -e "\nCI/CD starts"

echo "----------------------------------------------------------------------------"
echo -e "Step 1/9: Create lab\n"

cd $storage
mkdir $lab
cd $lab

echo -e "\nDone 1/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 2/9: Cloning repositories\n"

git clone "https://git:SBBIRAN%))GIT@g.sbbiran.com/$name/$name-api.git" api
git clone "https://git:SBBIRAN%))GIT@g.sbbiran.com/$name/$name-ui.git" ui

echo -e "\nDone 2/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 3/9: Copying envs\n"

cp $dir/envs/$name/.env ui

echo -e "\nDone 3/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 4/9: Installing UI dependencies\n"

cd $storage/$lab/ui
yarn install

echo -e "\nDone 4/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 5/9: Builiding production\n"

latCommitUI=$(git log --pretty="format:%s" -n1)

yarn build

echo -e "\nDone 5/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 6/9: Copy build to API\n"

cd $storage/$lab/api
rm -rf build
cp -r $storage/$lab/ui/build .

echo -e "\nDone 6/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 7/9: Commit and push\n"

git status

# git add -A
# git commit -m "CI/CD build commit $now | $latCommitUI"
# git push origin master

echo -e "\nDone 7/9"
echo "----------------------------------------------------------------------------"
echo -e "Step 8/9: Delete lab\n"

# cd $storage
# rm -rf $lab

echo -e "\nDone 8/9"
echo "----------------------------------------------------------------------------"

echo "CI/CD done"
echo -e "Your project is ready!\n"

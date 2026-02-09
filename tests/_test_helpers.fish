function setup_test_repo --argument-names branch
    set -l tmpdir (mktemp -d)
    mkdir -p $tmpdir/repository
    cd $tmpdir/repository
    git init --initial-branch=$branch -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    touch test.txt
    git add test.txt
    git commit -m "Initial commit" -q
    echo $tmpdir
end

function cleanup_test_repo --argument-names directory
    if string match --quiet '/tmp/tmp.*' $directory
        and test -d $directory
        rm -rf $directory
    end
end

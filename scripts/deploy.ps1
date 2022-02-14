
$Commit =  git show -s --format=%B | Select-Object -First 1

if(!(Test-Path -Path ".\build\web")){
    mkdir ".\build\web"
}

Set-Location ".\build\web\"

if (Test-Path -Path "./.git") {
    git pull origin main
} else {
    git clone git@github.com:Team1690/Team1690.github.io.git .
}
flutter build web --web-renderer html --release 
git add . 
git commit -m $Commit
git push origin main
Set-Location ../..
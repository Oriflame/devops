# devops
Tools, build pipelines etc for Azure DEVOPS. Project follows [gitflow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) for development&releases.

## Scripts

This section contains links to documentation about available scripts

### [init-repo](docs/init-repo.md)

Script, that will initialize your repository with develop branch and pull requests policies over master, develop, feature etc. branches.

## How to contribute

See [contributing.md](CONTRIBUTING.md).

### Signed commits

You need to have signed commits to commit to this repository. For Windows & Visual Studio follow these steps:

* generate new gpg private key via [GNU gpg](https://chocolatey.org/packages/gnupg), e.g. `gpg --full-generate-key`, details here: [generate new gpg key](https://help.github.com/en/articles/generating-a-new-gpg-key).
* register public key with Github, e.g. `git config --global user.signingkey 1234567890ABCDEF`, see [telling git about your gpg key](https://help.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key).
* adjust git .config to sign the requests, e.g. `git config --global commit.gpgsign true`, see [Securely sign git commits in visual studio](https://www.andrewhoefling.com/Blog/Post/securely-sign-git-commits-in-visual-studio)
* when you commit you will be asked for a passphrase for your private key, be sure you store it in a secure way, e.g. via [Keepass](https://keepass.info/).

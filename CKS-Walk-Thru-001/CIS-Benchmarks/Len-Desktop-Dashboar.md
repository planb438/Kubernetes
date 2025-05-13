### Len-Desktop-Dashboar
Lens Desktop is lightweight and simple to install on all major platforms. Download  Lens Desktop and start managing your Kubernetes clusters comfortably and efficiently. This page contains installation instructions for various platforms and covers other related topics.


Install Lens Desktop from the APT repository#
1. Get the Lens Desktop public security key and add it to your keyring:
curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null


2. Add the Lens Desktop repo to your /etc/apt/sources.list.d directory.
Ubuntu newer than 18.04Ubuntu 18.04
Specify the stable channel:
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | sudo tee /etc/apt/sources.list.d/lens.list > /dev/null







3. Install or update Lens Desktop:
sudo apt update && sudo apt install lens


4. Run Lens Desktop:
lens-desktop




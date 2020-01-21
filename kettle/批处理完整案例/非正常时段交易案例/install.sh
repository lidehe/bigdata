mkdir -p ~/job
mkdir -p ~/shell
chmod +x run.sh
uzip pdi-ce-8.3.0.0-371.zip
echo "export kettle_home=/home/${USER}/data-integration" >>/home/${USER}/.bash_profile
echo "export PATH="'${PATH}'":"'${kettle_home}'"">>/home/${USER}/.bash_profile

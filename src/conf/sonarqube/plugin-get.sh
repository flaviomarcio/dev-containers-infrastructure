export verion=1.18.0
export name=sonarqube-community-branch-plugin-${version}.jar
mkdir -p ${PWD}/extensions/plugins
cd ${PWD}/extensions/plugins
rm -rf ${name}
wget https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${version}/${name}
#!/bin/tcsh


set toolPath="/Volumes/User/inacio/Downloads/xmlschematograph-commandline"

echo java -jar ${toolPath}/XmlSchemaToGraph.jar -o $1:r.dot file:`pwd`/${1}
java -jar ${toolPath}/XmlSchemaToGraph.jar -o $1:r.dot file:`pwd`/${1}

 
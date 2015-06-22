#!/bin/bash

get_taxonomies() {
    local blog_url=$1
    local user=$2
    local pass=$3

    XML=$(cat <<EOF 
<?xml version='1.0' encoding='iso-8859-1'?>
<methodCall>
  <methodName>wp.getTaxonomies</methodName>
  <params>
    <param><value><int>0</int></value></param>
    <param><value><string>${user}</string></value></param>
    <param>
      <value><string>${pass}</string>
      </value>
    </param>
  </params>
</methodCall>
EOF
)
    echo "xml: $XML"
    local response=$(curl -ksS -H "Content-Type: application/xml" -X POST --data-binary "${XML}" $blog_url/xmlrpc.php)
    echo "Response: $response"
    
}


get_categories() {
    local blog_url=$1
    local user=$2
    local pass=$3

    XML=$(cat <<EOF 
<?xml version='1.0' encoding='iso-8859-1'?>
<methodCall>
  <methodName>wp.getCategories</methodName>
  <params>
    <param><value><int>0</int></value></param>
    <param><value><string>${user}</string></value></param>
    <param>
      <value><string>${pass}</string>
      </value>
    </param>
  </params>
</methodCall>
EOF
)
    echo "xml: $XML"
    local response=$(curl -ksS -H "Content-Type: application/xml" -X POST --data-binary "${XML}" $blog_url/xmlrpc.php)
    echo "Response: $response"
    
}



new_category() {
    local blog_url=$1
    local user=$2
    local pass=$3
    local cat=$4

    XML=$(cat <<EOF 
<?xml version='1.0' encoding='iso-8859-1'?>
<methodCall>
  <methodName>wp.newCategory</methodName>
  <params>
    <param><value><int>0</int></value></param>
    <param><value><string>${user}</string></value></param>
    <param><value><string>${pass}</string></value></param>
    <param>
        <struct>
          <member>
            <name>name</name>
            <value>
              <string>${cat}</string>
            </value>
          </member>
          <member>
            <name>taxonomy</name>
            <value>
              <string>category</string>
            </value>
          </member>
        </struct>
    </param>
  </params>
</methodCall>
EOF
)
    echo "xml: $XML"
    local response=$(curl -ksS -H "Content-Type: application/xml" -X POST --data-binary "${XML}" $blog_url/xmlrpc.php)
    echo "Response: $response"
    
}


get_tags() {
    local blog_url=$1
    local user=$2
    local pass=$3

    XML=$(cat <<EOF 
<?xml version='1.0' encoding='iso-8859-1'?>
<methodCall>
  <methodName>wp.getTags</methodName>
  <params>
    <param><value><int>0</int></value></param>
    <param><value><string>${user}</string></value></param>
    <param>
      <value><string>${pass}</string>
      </value>
    </param>
  </params>
</methodCall>
EOF
)
    echo "xml: $XML"
    local response=$(curl -ksS -H "Content-Type: application/xml" -X POST --data-binary "${XML}" $blog_url/xmlrpc.php)
    echo "Response: $response"
    
}

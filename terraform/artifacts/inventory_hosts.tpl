[central_servers]
%{ for ip in cs_ip ~}
${ip} 
%{ endfor ~}

[message_processors]
%{ for ip in mp_ip ~}
${ip} 
%{ endfor ~}



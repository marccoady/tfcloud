# ---- .net/outputs.tf

output "vpc_id" {
  value = aws_vpc.ttp_vpc.id
}
output "pb_sg" {
  value = aws_security_group.ttp_pb_sg.id
}

output "pt_sg" {
  value = aws_security_group.ttp_pt_sg.id
}

output "web_sg" {
  value = aws_security_group.ttp_web_sg.id
}

output "pt_sn" {
  value = aws_subnet.ttp_pt_sn[*].id
}

output "pb_sn" {
  value = aws_subnet.ttp_pb_sn[*].id
}
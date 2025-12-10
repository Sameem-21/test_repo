Instance_id= $(terraform output -raw aws_instance_id)
Public_ip= $(terraform output -raw aws_instance_public_ip)
Instance_name= $(terraform output -raw aws_instance_name)
availability_zone= $(terraform output -raw aws_az)
USER="ubuntu"

KEY_PATH="$HOME/.ssh/temp-key"
if [ ! -f "$KEY_PATH" ]; then
  echo "🔑 Generating temporary SSH key..."
  ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N "" -q
fi

echo "📤 Sending SSH public key to EC2 InstanceConnect..."
aws ec2-instance-connect send-ssh-public-key \
  --instance-id "$Instance_id" \
  --instance-os-user "$USER" \
  --ssh-public-key file://"$KEY_PATH.pub" \
  --availability-zone "$availability_zone"

echo "🔗 Connecting to EC2 instance at $Public_ip..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" "$USER@$Public_ip" <<'EOF'
  echo "✅ Connection Successful" > connection_test.txt
  cat connection_test.txt
EOF
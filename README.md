# nginx-gunicorn-example

## Instructions

1: Clone this repo with: `git clone https://github.com/korry8911/nginx-gunicorn-example.git`

2: Launch Centos 7 (ami-d2c924b2) EC2 in AWS and note its public domain name

3: Copy `setup.sh` from the cloned repo to the EC2 instance with: `scp -i ~/path/to/ec2-key.pem ~/path/to/nginx-gunicorn-example/setup.sh centos@ec2.domain.name.com:setup.sh`

4: SSH into the EC2 instance with: `ssh -i ~/path/to/ec2-key.pem centos@ec2.domain.name.com`

5: Run `setup.sh` from the EC2 instance with: `sudo sh setup.sh`

6: After `setup.sh` completes, open a browser and navigate to `ec2.domain.name.com`. Should see `'Hello World'`

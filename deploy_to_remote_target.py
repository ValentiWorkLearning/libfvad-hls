import argparse
from pathlib import Path
import paramiko
from scp import SCPClient

def deploy_with_ssh(
    local_path: Path, 
    remote_path: Path, 
    raspberry_ip: str, 
    username: str, 
    password: str
) -> None:
    """Deploy files to Raspberry Pi using SSH and SCP.

    Args:
        local_path (Path): The local directory or file path to deploy.
        remote_path (Path): The destination path on the Raspberry Pi.
        raspberry_ip (str): The IP address of the Raspberry Pi.
        username (str): The SSH username for the Raspberry Pi.
        password (str): The SSH password for the Raspberry Pi.
    """
    try:
        local_path = local_path.resolve()
        if not local_path.exists():
            raise FileNotFoundError(f"Local path '{local_path}' does not exist.")
        
        remote_path = remote_path.as_posix()

        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(raspberry_ip, username=username, password=password)

        with SCPClient(ssh.get_transport()) as scp:
            scp.put(str(local_path), remote_path, recursive=local_path.is_dir())
        
        print(f"Deployment to {raspberry_ip} successful!")
    except Exception as e:
        print(f"Error during deployment: {e}")

def main() -> None:
    parser = argparse.ArgumentParser(description="Deploy an app to a Raspberry Pi using SSH and SCP.")
    parser.add_argument("--ip", type=str, help="The IP address of the Raspberry Pi.")
    parser.add_argument("--username", type=str, default="pi", help="The username for the Raspberry Pi (default: 'pi').")
    parser.add_argument("--password", type=str, default="raspberry", help="The password for the Raspberry Pi (default: 'raspberry').")
    parser.add_argument("--local-path", type=Path, required=True, help="The local path of the app to deploy.")
    parser.add_argument("--remote-path", type=Path, required=True, help="The destination path on the Raspberry Pi.")

    args = parser.parse_args()

    deploy_with_ssh(
        local_path=args.local_path,
        remote_path=args.remote_path,
        raspberry_ip=args.ip,
        username=args.username,
        password=args.password
    )

if __name__ == "__main__":
    main()

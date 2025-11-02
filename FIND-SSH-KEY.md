# Find Your SSH Key

## Where is your SSH key?

You need to provide the **correct path** to your SSH key file (`.pem` file) when deploying.

## Common Locations

### macOS/Linux

```bash
# Check common locations
ls -la ~/.ssh/

# Common key names:
# - id_rsa (private key)
# - id_rsa.pub (public key)
# - your-key.pem (EC2 key pair)
# - ec2-key.pem
# - aws-key.pem
```

### If you downloaded it from AWS Console

It's usually in your `Downloads` folder:

```bash
# macOS
~/Downloads/your-key-name.pem

# Or check Downloads
ls -la ~/Downloads/*.pem
```

### If you created it with AWS CLI

```bash
# Check your ~/.ssh directory
ls -la ~/.ssh/*.pem
```

## Find Your Key

Run these commands to find your key:

```bash
# Find all .pem files
find ~ -name "*.pem" -type f 2>/dev/null

# Or check common locations
ls -la ~/.ssh/*.pem 2>/dev/null
ls -la ~/Downloads/*.pem 2>/dev/null
ls -la ~/Desktop/*.pem 2>/dev/null
```

## Set Correct Permissions

Once you find your key:

```bash
# Set correct permissions (required for SSH)
chmod 400 /path/to/your-key.pem

# Or
chmod 600 /path/to/your-key.pem
```

## Use Full Path or Relative Path

When deploying, you can use:

**Full path:**

```bash
./scripts/deploy.sh --ec2 16.16.198.187 /Users/yourname/.ssh/my-key.pem ubuntu
```

**Tilde (~) expansion:**

```bash
./scripts/deploy.sh --ec2 16.16.198.187 ~/.ssh/my-key.pem ubuntu
```

**Relative path (from current directory):**

```bash
./scripts/deploy.sh --ec2 16.16.198.187 ./my-key.pem ubuntu
```

## Example

If your key is at `~/.ssh/ec2-key.pem`:

```bash
# Set permissions first
chmod 400 ~/.ssh/ec2-key.pem

# Then deploy
./scripts/deploy.sh --ec2 16.16.198.187 ~/.ssh/ec2-key.pem ubuntu
```

## If You Don't Have the Key

If you don't have the SSH key anymore:

1. **Create a new key pair in AWS Console:**
   - EC2 → Key Pairs → Create key pair
   - Download the `.pem` file
   - Save it in `~/.ssh/`

2. **Or use AWS CLI:**

   ```bash
   aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > ~/.ssh/my-key.pem
   chmod 400 ~/.ssh/my-key.pem
   ```

3. **Attach to instance:**
   - Stop the instance
   - Create AMI or use Systems Manager
   - Or launch a new instance with the new key

## Verify Key Works

Test the key before deploying:

```bash
# Test SSH connection
ssh -i ~/.ssh/your-key.pem ubuntu@16.16.198.187

# If this works, the deploy will work too!
```

## Common Errors

### "Permission denied (publickey)"

- Key permissions are wrong: `chmod 400 your-key.pem`
- Wrong key file
- Wrong username (should be `ubuntu` for Ubuntu AMI)

### "No such file or directory"

- Key file path is wrong
- File doesn't exist at that location
- Use full path instead of tilde

### "Bad permissions"

- Fix with: `chmod 400 your-key.pem`
- Should be readable only by owner

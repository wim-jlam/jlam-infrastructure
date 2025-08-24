# 🛡️ DISASTER RECOVERY PROCEDURES
*Created: 2025-08-24*  
*Baseline Version: v1.0.0-baseline*  
*Last Verified: 2025-08-24*

## 🎯 GOLDEN MASTER BASELINE

**What it is**: A fully working, reproduceable Infrastructure as Code configuration  
**Status**: ✅ VERIFIED WORKING on 2025-08-24  
**Deployment**: `51.158.190.109` → `https://jlam.nl`

### ✅ Verified Working Services:
- **HTTPS Website**: `https://jlam.nl` → 200 OK (nginx)
- **Traefik Dashboard**: `http://51.158.190.109:8080` → 200 OK
- **SSL Certificates**: Sectigo wildcard certificate working
- **Docker Services**: Traefik + nginx running automatically
- **Auto-deployment**: Complete cloud-init automation

---

## 🚨 EMERGENCY RECOVERY PROCEDURES

### **Option A: Revert to Baseline (Code Only)**
*Use when: Code changes broke something, server is still running*

```bash
# 1. Revert to baseline code
git checkout v1.0.0-baseline

# 2. Re-apply working configuration  
terraform init
terraform plan
terraform apply

# 3. Verify services are working
curl -I https://jlam.nl
curl -I http://51.158.190.109:8080/dashboard/
```

### **Option B: Complete Server Rebuild**  
*Use when: Server is completely broken or compromised*

```bash
# 1. Get baseline code
git clone https://github.com/wim-jlam/jlam-infrastructure.git
cd jlam-infrastructure
git checkout v1.0.0-baseline

# 2. Set environment variables (from Terraform Cloud)
export SCW_ACCESS_KEY="<from-terraform-cloud>"
export SCW_SECRET_KEY="<from-terraform-cloud>" 
export SCW_DEFAULT_PROJECT_ID="<from-terraform-cloud>"

# 3. Initialize terraform
terraform init

# 4. Deploy new server (will use existing IP)
terraform apply -auto-approve

# 5. Wait 5 minutes for cloud-init to complete
sleep 300

# 6. Verify everything is working
curl -I https://jlam.nl
curl -I http://51.158.190.109:8080/dashboard/
```

### **Option C: Quick Verification**
*Use when: Need to check if baseline is still working*

```bash
# Test all critical endpoints
curl -I https://jlam.nl                           # Should return: 200 OK
curl -I http://51.158.190.109:8080/dashboard/     # Should return: 200 OK
curl -I http://51.158.190.109                     # Should return: 404 (expected)

# Check SSL certificate
openssl s_client -connect jlam.nl:443 -servername jlam.nl < /dev/null | grep "Verify return code"
# Should return: Verify return code: 0 (ok)
```

---

## 📋 RECOVERY CHECKLIST

### Before Any Recovery:
- [ ] Backup current state if needed: `git commit -am "Pre-recovery backup"`
- [ ] Verify Terraform Cloud credentials are working
- [ ] Confirm DNS is pointing to correct IP: `dig jlam.nl`
- [ ] Take note of current server status

### After Recovery:
- [ ] HTTPS website responding: `curl -I https://jlam.nl`
- [ ] Traefik dashboard accessible: `curl -I http://51.158.190.109:8080/dashboard/`
- [ ] SSL certificate valid: Check browser for green lock
- [ ] DNS resolving correctly: `dig jlam.nl` → `51.158.190.109`
- [ ] Docker services running: SSH check if needed
- [ ] Create recovery log entry below

---

## 📊 RECOVERY LOG

### 2025-08-24 - Initial Baseline Creation
- **Status**: ✅ Success
- **Action**: Created v1.0.0-baseline with proven working configuration
- **Result**: HTTPS jlam.nl working, Traefik dashboard accessible
- **Duration**: N/A (initial creation)
- **Notes**: Reverse-engineered from manual configuration, fully tested

### [Next recovery will be logged here]

---

## 🔧 TROUBLESHOOTING

### Common Issues & Solutions:

**Problem**: `terraform apply` fails  
**Solution**: Check Terraform Cloud credentials and run `terraform init`

**Problem**: HTTPS not working after recovery  
**Solution**: Wait 5 minutes for cloud-init, then check Docker containers

**Problem**: Traefik dashboard not accessible  
**Solution**: Verify port 8080 is open in security group

**Problem**: DNS not resolving  
**Solution**: Check if IP address changed, update DNS if needed

**Problem**: SSL certificate errors  
**Solution**: Verify certificate files are properly base64 encoded in template

---

## 🎯 CONFIDENCE INDICATORS

### High Confidence Recovery (Green):
- ✅ Git tag `v1.0.0-baseline` exists and tested
- ✅ Terraform Cloud workspace configured
- ✅ All credentials accessible
- ✅ DNS pointing to correct IP
- ✅ Last verification < 7 days ago

### Medium Confidence (Yellow):
- ⚠️ Last verification 7-30 days ago
- ⚠️ Minor configuration drift detected
- ⚠️ Terraform state inconsistencies

### Low Confidence (Red):
- ❌ Last verification > 30 days ago  
- ❌ Major infrastructure changes since baseline
- ❌ Terraform Cloud access issues
- ❌ DNS or IP changes

---

## 🚀 NEXT STEPS AFTER RECOVERY

1. **Update this document** with recovery details
2. **Test all services** thoroughly  
3. **Create new baseline** if significant improvements made
4. **Update team** on recovery status
5. **Plan improvements** to prevent future issues

---

*Remember: This baseline was battle-tested and verified working.*  
*When in doubt, revert to baseline first, then investigate.*
## 📧 Configure & Test Basic E-mail Notification in Jenkins

_(Used to verify Gmail SMTP before Extended E-mail Plugin setup)_

Even though the **Extended E-mail Plugin** provides more features, setting up **E-mail Notification** first helps confirm that Gmail SMTP connectivity works correctly.

---

### ⚙️ **Steps: Enable and Test Basic E-mail Notification**

1. Go to **Manage Jenkins → System Configuration → Configure System**

2. Scroll down to the **E-mail Notification** section

3. Fill in the following fields:

   | Field                          | Value            |
   | ------------------------------ | ---------------- |
   | **SMTP server**                | `smtp.gmail.com` |
   | **Default user e-mail suffix** | `@gmail.com`     |

4. Click **Advanced ▼**, then enable and fill in these:

   - ✅ **Use SMTP Authentication**
   - **User Name:** `ofosubernard848@gmail.com`
   - **Password:** _(App Password from [Google App Passwords](https://myaccount.google.com/apppasswords))_
   - ❌ **Use SSL:** _unchecked_
   - ✅ **Use TLS:** _checked_
   - **SMTP Port:** `587`
   - **Reply-To Address:** `ofosubernard848@gmail.com`
   - **Charset:** `UTF-8`

5. Check ✅ **“Test configuration by sending test e-mail”**

   - **Test e-mail recipient:** `ofosubernard357@gmail.com`

6. Click **Test configuration**

   - You should see:
     🟢 _“Email was successfully sent”_

7. Confirm the email arrives in the recipient’s inbox.

---

### 💡 **Why This Matters**

- Even **without configuring the Extended E-mail Plugin**, this simple test verifies that:

  - Jenkins can reach Gmail’s SMTP server (port 587).
  - The App Password works properly.
  - Network/firewall rules are correct.

✅ Once this test succeeds, the **Extended E-mail Notification Plugin** will work flawlessly, since it relies on the same SMTP configuration under the hood.

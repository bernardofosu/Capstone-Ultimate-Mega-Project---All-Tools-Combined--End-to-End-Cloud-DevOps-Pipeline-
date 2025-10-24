# 🧩 Jenkins Pipeline Creation Guide (Mega-Project)

---

## **1️⃣ Create a New Pipeline Project**
1. Go to **Jenkins Dashboard → New Item**.  
2. Enter a project name — e.g. **Mega-Project**.  
3. Select **“Pipeline”** as the project type.  
4. Click **OK**.  

🧠 *This creates a new Jenkins pipeline job where you’ll define your CI/CD stages.*

---

## **2️⃣ General Configuration**
1. (Optional) Add a **Description** for your project.  
2. Tick ✅ **“Discard old builds”**.  
3. Under **Strategy**, choose **Log Rotation**.  
4. Set values:  
   - **Days to keep builds** → *(leave blank or set as needed)*  
   - **Max # of builds to keep** → e.g. `2`  

🧠 *This keeps your Jenkins server clean by automatically deleting older builds.*

---

## **3️⃣ Configure the Pipeline Section**
1. Scroll down to the **Pipeline** section.  
2. Choose one of the following:  
   - **Definition:** `Pipeline script` → write your pipeline directly in Jenkins.  
   - **Definition:** `Pipeline script from SCM` → pull pipeline code from a Git repo.  
3. If you choose **SCM**:  
   - Select **Git**.  
   - Enter your **repository URL**.  
   - Add credentials if the repo is private.  
   - Set **Branch Specifier** (e.g. `*/main`).  
   - Enter **Script Path** as `Jenkinsfile`.  
4. Click **Save**.  

🧠 *This links Jenkins to your code repository and tells it where to find the pipeline script.*

---

## **4️⃣ Build and Run the Pipeline**
1. Go to your **Mega-Project** dashboard.  
2. Click **Build Now**.  
3. Open **Build History → Console Output** to view the logs.  

✅ *If configured correctly, Jenkins will automatically fetch the code, build it, and execute your defined stages.*

---

## 🧾 Summary

| Step | Action | Purpose |
|------|--------|----------|
| 1️⃣ | Create new item | Start a new Jenkins pipeline project |
| 2️⃣ | Configure General tab | Manage logs & build history |
| 3️⃣ | Define Pipeline | Connect to SCM or write inline script |
| 4️⃣ | Run Build | Execute your pipeline and view logs |

---

🚀 **Result:** Your Jenkins Pipeline project (**Mega-Project**) is now ready for CI/CD integration with Maven, SonarQube, Docker, and Kubernetes! 🔧

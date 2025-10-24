```java
pipeline {
    agent any

    stages {
        stage('Send Email') {
            steps {
                script {
                    // 🟩 or 🟥 change color based on manual status
                    def pipelineStatus = "SUCCESS"
                    def bannerColor = (pipelineStatus == "SUCCESS") ? "#28a745" : "#dc3545"

                    // ✉️ Email HTML body
                    def body = """
                        <html>
                        <body style="font-family:Arial,sans-serif;">
                            <div style="border:3px solid ${bannerColor}; border-radius:10px; padding:15px;">
                                <h2 style="color:${bannerColor};">📢 Jenkins Email Test</h2>
                                <p><b>From:</b> ofosubernard848@gmail.com</p>
                                <p><b>To:</b> ofosubernard357@gmail.com</p>
                                <p><b>Status:</b> <span style="color:${bannerColor}; font-weight:bold;">${pipelineStatus}</span></p>
                                <p>✅ This is a test email sent using the Extended Email Plugin.</p>
                                <hr/>
                                <p style="font-size:12px; color:#666;">Sent automatically by Jenkins 📬</p>
                            </div>
                        </body>
                        </html>
                    """

                    // 📤 Extended Email Plugin
                    emailext(
                        subject: "📧 Jenkins Email Test - ${pipelineStatus}",
                        body: body,
                        to: 'ofosubernard357@gmail.com',          // receiver
                        from: 'ofosubernard848@gmail.com',        // sender (must match Gmail App Password)
                        replyTo: 'ofosubernard8482024@gmail.com',
                        mimeType: 'text/html'
                    )
                }
            }
        }
    }
}
```

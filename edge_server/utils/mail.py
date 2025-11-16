from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
import os

conf = ConnectionConfig(
    MAIL_USERNAME=os.getenv("MAIL_USERNAME"),
    MAIL_PASSWORD=os.getenv("MAIL_PASSWORD"),
    MAIL_FROM=os.getenv("MAIL_FROM"),
    MAIL_SERVER=os.getenv("MAIL_SERVER", "smtp.gmail.com"),
    MAIL_PORT=587,
    MAIL_TLS=True,
    MAIL_SSL=False,
    USE_CREDENTIALS=True,
)

async def send_reset_email(email: str, token: str):
    reset_link = f"https://airchif.netlify.app/reset?token={token}"

    message = MessageSchema(
        subject="Passwort zurücksetzen",
        recipients=[email],
        body=f"Klicke auf diesen Link, um dein Passwort zurückzusetzen:\n{reset_link}",
        subtype="plain"
    )

    fm = FastMail(conf)
    await fm.send_message(message)

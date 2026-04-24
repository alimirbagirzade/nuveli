"""
Nuveli Backend — Başlangıç noktası.

Kullanım:
    python run.py

Otomatik olarak uvicorn ile app.main:app'i başlatır.
Development'ta hot-reload açıktır.
"""
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # Development: dosya değişince otomatik yeniden yükle
        log_level="info",
    )

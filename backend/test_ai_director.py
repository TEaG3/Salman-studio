import asyncio

import pytest

try:
    import ai_director
except ModuleNotFoundError:
    from backend import ai_director


def test_provider_is_disabled_by_default(monkeypatch):
    monkeypatch.delenv("TEAG3_AI_PROVIDER", raising=False)
    config = ai_director.configuration()
    assert config["provider"] == "rule_based"
    assert config["enabled"] is False


@pytest.mark.parametrize(
    "url, expected",
    [
        ("http://127.0.0.1:11434", True),
        ("http://localhost:11434", True),
        ("http://[::1]:11434", True),
        ("https://example.com", False),
        ("http://192.168.1.5:11434", False),
        ("http://127.0.0.1:8080", False),
        ("http://user:pass@127.0.0.1:11434", False),
        ("http://127.0.0.1:11434/proxy", False),
        ("http://127.0.0.1:bad", False),
    ],
)
def test_only_local_ollama_endpoint_is_allowed(monkeypatch, url, expected):
    monkeypatch.setenv("TEAG3_AI_PROVIDER", "gpt_oss_local")
    monkeypatch.setenv("TEAG3_OLLAMA_URL", url)
    assert ai_director.configuration()["safe_local"] is expected


def test_chat_requires_explicit_provider_enablement(monkeypatch):
    monkeypatch.setenv("TEAG3_AI_PROVIDER", "rule_based")
    with pytest.raises(ai_director.DirectorUnavailable):
        asyncio.run(ai_director.chat("Create a short video concept"))


def test_chat_parses_local_ollama_response(monkeypatch):
    monkeypatch.setenv("TEAG3_AI_PROVIDER", "gpt_oss_local")
    monkeypatch.setenv("TEAG3_OLLAMA_URL", "http://127.0.0.1:11434")
    monkeypatch.setenv("TEAG3_OLLAMA_MODEL", "gpt-oss:20b")

    class FakeResponse:
        def raise_for_status(self):
            return None

        def json(self):
            return {
                "model": "gpt-oss:20b",
                "message": {"content": "هذه خطة إبداعية تجريبية."},
                "done": True,
            }

    class FakeClient:
        def __init__(self, *args, **kwargs):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def post(self, *args, **kwargs):
            return FakeResponse()

    monkeypatch.setattr(ai_director.httpx, "AsyncClient", FakeClient)
    result = asyncio.run(ai_director.chat("اكتب فكرة إعلان قصيرة", "ar"))
    assert result["provider"] == "gpt_oss_local"
    assert result["response"] == "هذه خطة إبداعية تجريبية."
    assert result["mediaGenerated"] is False

import asyncio
import os
import unittest
from unittest.mock import patch

try:
    import ai_director
except ModuleNotFoundError:
    from backend import ai_director


class DirectorAdapterTests(unittest.TestCase):
    def test_provider_is_disabled_by_default(self):
        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("TEAG3_AI_PROVIDER", None)
            config = ai_director.configuration()
        self.assertEqual(config["provider"], "rule_based")
        self.assertFalse(config["enabled"])

    def test_all_providers_accept_only_their_localhost_port(self):
        cases = [
            ("gpt_oss_local", "TEAG3_OLLAMA_URL", "http://127.0.0.1:11434", True),
            ("deepseek_local", "TEAG3_DEEPSEEK_URL", "http://127.0.0.1:8001", True),
            ("kimi_local", "TEAG3_KIMI_URL", "http://localhost:8002", True),
            ("kimi_local", "TEAG3_KIMI_URL", "https://example.com", False),
            ("deepseek_local", "TEAG3_DEEPSEEK_URL", "http://192.168.1.4:8001", False),
            ("kimi_local", "TEAG3_KIMI_URL", "http://127.0.0.1:8001", False),
            ("gpt_oss_local", "TEAG3_OLLAMA_URL", "http://user:pass@127.0.0.1:11434", False),
            ("deepseek_local", "TEAG3_DEEPSEEK_URL", "http://127.0.0.1:8001/proxy", False),
            ("kimi_local", "TEAG3_KIMI_URL", "http://127.0.0.1:bad", False),
        ]
        for provider, env_key, url, expected in cases:
            with self.subTest(provider=provider, url=url), patch.dict(
                os.environ, {"TEAG3_AI_PROVIDER": provider, env_key: url}, clear=False
            ):
                self.assertEqual(ai_director.configuration()["safe_local"], expected)

    def test_chat_requires_explicit_provider_enablement(self):
        with patch.dict(os.environ, {"TEAG3_AI_PROVIDER": "rule_based"}, clear=False):
            with self.assertRaises(ai_director.DirectorUnavailable):
                asyncio.run(ai_director.chat("Create a short video concept"))

    def test_ollama_response_is_parsed(self):
        with patch.dict(os.environ, {
            "TEAG3_AI_PROVIDER": "gpt_oss_local",
            "TEAG3_OLLAMA_URL": "http://127.0.0.1:11434",
            "TEAG3_OLLAMA_MODEL": "gpt-oss:20b",
        }, clear=False):
            class FakeResponse:
                def raise_for_status(self): pass
                def json(self):
                    return {"model": "gpt-oss:20b", "message": {"content": "خطة تجريبية"}, "done": True}

            class FakeClient:
                def __init__(self, *args, **kwargs): pass
                async def __aenter__(self): return self
                async def __aexit__(self, *args): return False
                async def post(self, *args, **kwargs): return FakeResponse()

            with patch.object(ai_director.httpx, "AsyncClient", FakeClient):
                result = asyncio.run(ai_director.chat("اكتب فكرة إعلان", "ar"))
        self.assertEqual(result["provider"], "gpt_oss_local")
        self.assertEqual(result["response"], "خطة تجريبية")
        self.assertFalse(result["mediaGenerated"])

    def test_openai_compatible_kimi_response_is_parsed(self):
        with patch.dict(os.environ, {
            "TEAG3_AI_PROVIDER": "kimi_local",
            "TEAG3_KIMI_URL": "http://127.0.0.1:8002",
            "TEAG3_KIMI_MODEL": "moonshotai/Kimi-VL-A3B-Instruct",
        }, clear=False):
            class FakeResponse:
                def raise_for_status(self): pass
                def json(self):
                    return {"model": "moonshotai/Kimi-VL-A3B-Instruct",
                            "choices": [{"message": {"content": "تحليل تجريبي"}}]}

            class FakeClient:
                def __init__(self, *args, **kwargs): pass
                async def __aenter__(self): return self
                async def __aexit__(self, *args): return False
                async def post(self, *args, **kwargs): return FakeResponse()

            with patch.object(ai_director.httpx, "AsyncClient", FakeClient):
                result = asyncio.run(ai_director.chat("حلل هذا الطلب", "ar"))
        self.assertEqual(result["provider"], "kimi_local")
        self.assertEqual(result["response"], "تحليل تجريبي")
        self.assertFalse(result["mediaGenerated"])


if __name__ == "__main__":
    unittest.main()

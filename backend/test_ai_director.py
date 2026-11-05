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

    def test_only_local_ollama_endpoint_is_allowed(self):
        cases = [
            ("http://127.0.0.1:11434", True),
            ("http://localhost:11434", True),
            ("http://[::1]:11434", True),
            ("https://example.com", False),
            ("http://192.168.1.5:11434", False),
            ("http://127.0.0.1:8080", False),
            ("http://user:pass@127.0.0.1:11434", False),
            ("http://127.0.0.1:11434/proxy", False),
            ("http://127.0.0.1:bad", False),
        ]
        for url, expected in cases:
            with self.subTest(url=url), patch.dict(os.environ, {
                "TEAG3_AI_PROVIDER": "gpt_oss_local",
                "TEAG3_OLLAMA_URL": url,
            }, clear=False):
                self.assertEqual(ai_director.configuration()["safe_local"], expected)

    def test_chat_requires_explicit_provider_enablement(self):
        with patch.dict(os.environ, {"TEAG3_AI_PROVIDER": "rule_based"}, clear=False):
            with self.assertRaises(ai_director.DirectorUnavailable):
                asyncio.run(ai_director.chat("Create a short video concept"))

    def test_chat_parses_local_ollama_response(self):
        with patch.dict(os.environ, {
            "TEAG3_AI_PROVIDER": "gpt_oss_local",
            "TEAG3_OLLAMA_URL": "http://127.0.0.1:11434",
            "TEAG3_OLLAMA_MODEL": "gpt-oss:20b",
        }, clear=False):
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

            with patch.object(ai_director.httpx, "AsyncClient", FakeClient):
                result = asyncio.run(ai_director.chat("اكتب فكرة إعلان قصيرة", "ar"))

        self.assertEqual(result["provider"], "gpt_oss_local")
        self.assertEqual(result["response"], "هذه خطة إبداعية تجريبية.")
        self.assertFalse(result["mediaGenerated"])


if __name__ == "__main__":
    unittest.main()

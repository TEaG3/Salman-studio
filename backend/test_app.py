import tempfile
import unittest
from pathlib import Path
from fastapi.testclient import TestClient
import app as backend

class BackendTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        backend.DB_PATH = Path(self.temp.name) / "test.db"
        backend.initialize()
        self.client = TestClient(backend.app)

    def tearDown(self):
        self.temp.cleanup()

    def test_health_and_capabilities(self):
        self.assertEqual(self.client.get("/health").json()["status"], "ok")
        caps = self.client.get("/v1/capabilities").json()
        self.assertFalse(caps["videoGeneration"])

    def test_create_project_and_vertical_plan(self):
        project = self.client.post("/v1/projects", json={"name": "مشروعي"}).json()
        response = self.client.post(f"/v1/projects/{project['id']}/edit-plans", json={"brief": "فيديو عمودي 9:16 مع نص عربي"})
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json()["plan"]["profile"]["width"], 1080)
        self.assertEqual(response.json()["plan"]["profile"]["height"], 1920)

    def test_unknown_project_is_404(self):
        response = self.client.post("/v1/projects/missing/edit-plans", json={"brief": "make a video"})
        self.assertEqual(response.status_code, 404)

if __name__ == "__main__":
    unittest.main()

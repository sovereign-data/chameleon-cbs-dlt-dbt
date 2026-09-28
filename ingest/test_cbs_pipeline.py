from cbs_pipeline import odata_rows, strip


def test_strip_pads():
    assert strip({"RegioS": "NL01  ", "v": 1, "n": None}) == {"RegioS": "NL01", "v": 1, "n": None}


def test_follows_next_link(monkeypatch):
    pages = {"u1": {"value": [{"a": 1}], "odata.nextLink": "u2"}, "u2": {"value": [{"a": 2}]}}

    class R:
        def __init__(self, url):
            self.url = url

        def json(self):
            return pages[self.url]

    monkeypatch.setattr("cbs_pipeline.requests.get", lambda url, params=None: R(url))
    assert list(odata_rows("u1")) == [{"a": 1}, {"a": 2}]

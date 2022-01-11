import requests
from skimage import io
import json
import matplotlib.pyplot as plt
import numpy as np
import urllib.request

resp = requests.post("http://localhost:8001/digitreg",
                     files={"file":"hey"})


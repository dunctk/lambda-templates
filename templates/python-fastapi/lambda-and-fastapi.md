Here’s how you can leverage **uv** to build a ZIP‑based deployment package (Approach 1: native ZIP + Mangum) for your FastAPI + HTML‑rendering app on AWS Lambda:

1. **Initialize your project with uv**
   In your project root (where you’ll keep `app/` and your FastAPI code), create a `pyproject.toml` if you haven’t already:

   ```bash
   cd project
   uv init --app
   ```

   This bootstraps a FastAPI‐ready layout and creates a `pyproject.toml` with a `[project]` table ([Astral][1]).

2. **Declare your dependencies**
   In `pyproject.toml`, under `[project]`, add at least:

   ```toml
   dependencies = [
     "fastapi",
     "mangum",
     "jinja2"      # for HTML templates
   ]
   ```

   (If you also want the FastAPI dev server locally, add it under `[dependency‑groups.dev]` as `"fastapi[standard]>=…"`.) ([Astral][1])

3. **Export a frozen requirements.txt**
   Freeze exactly the production deps (no dev or editable):

   ```bash
   uv export --frozen --no-dev --no-emit-workspace -o requirements.txt
   ```

   This will generate a lock‐pinned `requirements.txt` suitable for Lambda ([Astral][1]).

4. **Install into a local “packages” directory**
   Tell uv’s pip interface to install those wheels into `packages/` using the same manylinux platform Lambda expects:

   ```bash
   uv pip install \
     --no-installer-metadata \
     --no-compile-bytecode \
     --python-platform x86_64-manylinux2014 \
     --python 3.13 \
     --target packages \
     -r requirements.txt
   ```

   This mirrors the “Deploying a zip archive” steps from the uv docs ([Astral][1]).

5. **Bundle your code + deps into a ZIP**

   ```bash
   # 1) Zip up all dependencies
   cd packages
   zip -r ../package.zip .
   cd ..

   # 2) Add your FastAPI app code
   zip -r package.zip app
   ```

6. **Upload to Lambda**

   ```bash
   aws lambda update-function-code \
     --function-name myFastApiFunction \
     --zip-file fileb://package.zip
   ```

   Make sure your handler is set to `app.main.handler` (or `your_module.handler`) in the Lambda configuration.

7. **(Optional) Use a Lambda Layer**
   If you prefer, you can publish `packages/` as a layer and then zip only your app folder.  That lets you update deps independently:

   ```bash
   # Publish the layer
   zip -r layer.zip packages
   aws lambda publish-layer-version \
     --layer-name fastapi-deps \
     --zip-file fileb://layer.zip \
     --compatible-runtimes python3.13

   # Then just zip your code:
   zip -r app.zip app
   aws lambda update-function-code \
     --function-name myFastApiFunction \
     --zip-file fileb://app.zip
   aws lambda update-function-configuration \
     --function-name myFastApiFunction \
     --layers arn:aws:lambda:…:layer:fastapi-deps:1
   ```

   This approach is exactly the ZIP + layer pattern shown in the uv docs ([Astral][1]).

---

With these steps, **uv** handles all the heavy lifting around dependency resolution, lock‑pinning, and package installation—letting you focus on your FastAPI code and the Mangum handler.

[1]: https://docs.astral.sh/uv/guides/integration/aws-lambda/ "Using uv with AWS Lambda | uv"


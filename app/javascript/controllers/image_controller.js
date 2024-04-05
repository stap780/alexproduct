import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage";
import { post } from "@rails/request.js"

// Connects to data-controller="image-upload"
export default class extends Controller {

  static targets = ["filesInput","fileItem","actionUrl"];

  // Bind to normal file selection
  uploadFile(event) {
    const filesInput = this.filesInputTarget;
    const url = filesInput.dataset.directUploadUrl;
    const actionUrl = this.actionUrlTarget.dataset.modelActionUrl;
    Array.from(filesInput.files).forEach(file => {
      console.log('actionUrl',actionUrl)
      //console.log('file',file)
      this.createUploadController(file, url, actionUrl).start();
    })
    filesInput.value = "";
  }
  removeFile(event) {
    // not use
  }


  createUploadController(file, url, actionUrl) {
    return new DirectUploadController(file, url, actionUrl);
  }
}

class DirectUploadController {
  constructor(file, url, actionUrl) {
    this.directUpload = this.createDirectUpload(file, url, this);
    this.file = file;
    this.actionUrl = actionUrl;
  }

  start() {
    // console.log('start');
    this.directUpload.create((error, blob) => {
      if (error) {
        // Handle the error
        alert(error);
      } else {
        // console.log('blob',blob);
        this.uploadToActiveStorage(blob);
        // Add an appropriately-named hidden input to the form
        // with a value of blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
  }

  createDirectUpload(file, url, controller) {
    return new DirectUpload(file, url, controller);
  }

  async uploadToActiveStorage(blob) {
    const response = await post(this.actionUrl, {
      body: JSON.stringify({ blob_signed_id: blob.signed_id}),
      responseKind: "turbo-stream",
    })
    
    return response.status === 204
  }

}
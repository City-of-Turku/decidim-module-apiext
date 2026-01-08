$(() => {
  const copyToClipboard = document.getElementById("api-user-token")
  if(!copyToClipboard) {
    return
  }

  const tokenInput = document.getElementById("token");
  if(!tokenInput) {
    return
  }
  const copyToken = () => {
    tokenInput.select();
    navigator.clipboard.writeText(tokenInput.value);
  }

  const replaceText = () => {
    let spanElement = document.createElement("span");
    let parentElement = copyToClipboard.parentNode;
    spanElement.textContent = copyToClipboard.dataset.action;
    parentElement.insertBefore(spanElement, copyToClipboard.nextSibling);
    parentElement.removeChild(copyToClipboard);
    parentElement.removeChild(tokenInput);
  }
  copyToClipboard.addEventListener("click",(ev) => {
    ev.preventDefault();
    copyToken();
    replaceText();
  })
})

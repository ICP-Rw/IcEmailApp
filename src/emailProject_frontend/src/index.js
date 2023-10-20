import { backend } from "../../declarations/backend";

document.getElementById("btn").addEventListener("click", async (e) => {
  e.preventDefault();

  const button = document.getElementById("btn");

  const name = document.getElementById("name").value.toString();

  const userEmail = document.getElementById("email").value.toString();

  button.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const greeting = await backend.sendEmailNotification(name, userEmail);
  console.log("email send result :", greeting);
  button.removeAttribute("disabled");

  document.getElementById("greeting").innerText =
    "Email sent to " + userEmail + " : " + greeting;

  return false;
});

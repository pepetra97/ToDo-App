// main.js
function deleteTodo(todoId) {
    fetch(`/todos/${todoId}`, {
        method: "DELETE",
    })
    .then((response) => {
        if (response.ok) {
            location.reload();
        } else {
            console.error("Error deleting todo");
        }
    })
    .catch((error) => {
        console.error("Error:", error);
    });
}

document.addEventListener("DOMContentLoaded", () => {
    const doneButtons = document.querySelectorAll(".done-button");
    doneButtons.forEach((button) => {
        button.addEventListener("click", (event) => {
            const todoItem = event.target.closest(".todo-item");
            todoItem.classList.toggle("done");
        });
    });
});

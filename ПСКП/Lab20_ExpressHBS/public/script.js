window.onload = function () {
    const editField = document.getElementById('editField');
    const deleteBtn = document.getElementById('deleteBtn');

    if (editField && deleteBtn) {
        editField.addEventListener('input', function () {
            if (editField.value.length > 0) {
                deleteBtn.disabled = true;
            }
        });
    }
};
document.addEventListener("DOMContentLoaded", () => {
  const durationOptions = document.querySelectorAll("[data-duration]");
  const rewardValue = document.querySelector("[data-reward-value]");
  const rewardLabel = document.querySelector("[data-reward-label]");

  durationOptions.forEach((option) => {
    option.addEventListener("click", () => {
      durationOptions.forEach((node) => node.classList.remove("active"));
      option.classList.add("active");
      if (rewardValue) rewardValue.textContent = option.dataset.coins;
      if (rewardLabel) rewardLabel.textContent = option.dataset.duration;
    });
  });

  const longTermToggle = document.querySelector("[data-long-term-toggle]");
  const subgoalSection = document.querySelector("[data-subgoal-section]");
  if (longTermToggle && subgoalSection) {
    longTermToggle.addEventListener("change", (event) => {
      subgoalSection.style.display = event.target.checked ? "block" : "none";
    });
  }

  const addSubgoalButton = document.querySelector("[data-add-subgoal]");
  const subgoalList = document.querySelector("[data-subgoal-list]");
  if (addSubgoalButton && subgoalList) {
    addSubgoalButton.addEventListener("click", () => {
      const count = subgoalList.querySelectorAll(".subgoal-row").length + 1;
      const wrapper = document.createElement("div");
      wrapper.className = "subgoal-row";
      wrapper.innerHTML = `
        <div class="task-check"><i class="fa-solid fa-wand-sparkles"></i></div>
        <div style="flex: 1;">
          <div class="input-shell">
            <input type="text" placeholder="Subgoal ${count}: define the next concrete action">
          </div>
        </div>
      `;
      subgoalList.appendChild(wrapper);
    });
  }
});

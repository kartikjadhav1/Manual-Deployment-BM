// Dark Mode Toggle
const darkModeBtn = document.getElementById('darkModeBtn');
const body = document.body;

darkModeBtn.addEventListener('click', (e) => {
    e.preventDefault();
    body.classList.toggle('dark');
    darkModeBtn.textContent = body.classList.contains('dark') ? '☀️ Light Mode' : '🌙 Dark Mode';
    localStorage.setItem('darkMode', body.classList.contains('dark'));
});

// Load dark mode preference
if (localStorage.getItem('darkMode') === 'true') {
    body.classList.add('dark');
    darkModeBtn.textContent = '☀️ Light Mode';
}

// Search functionality
const searchBox = document.getElementById('searchBox');
searchBox.addEventListener('input', (e) => {
    const searchTerm = e.target.value.toLowerCase();
    const cards = document.querySelectorAll('.card');
    
    cards.forEach(card => {
        const destination = card.getAttribute('data-destination').toLowerCase();
        const wrapper = card.closest('.card-wrapper');
        
        if (destination.includes(searchTerm)) {
            wrapper.style.display = 'block';
        } else {
            wrapper.style.display = 'none';
        }
    });
});

// Filter functionality
const filterBtns = document.querySelectorAll('.filter-btn');
filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        filterBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        const filter = btn.getAttribute('data-filter');
        const cards = document.querySelectorAll('.card-wrapper');
        
        cards.forEach(card => {
            if (filter === 'all' || card.getAttribute('data-category').includes(filter)) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    });
});

// Wishlist functionality
let wishlist = JSON.parse(localStorage.getItem('wishlist')) || [];

document.querySelectorAll('.wishlist-btn').forEach(btn => {
    const id = btn.getAttribute('data-id');
    if (wishlist.includes(id)) {
        btn.classList.add('active');
        btn.textContent = '♥';
    }
    
    btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const id = btn.getAttribute('data-id');
        
        if (wishlist.includes(id)) {
            wishlist = wishlist.filter(item => item !== id);
            btn.classList.remove('active');
            btn.textContent = '♡';
        } else {
            wishlist.push(id);
            btn.classList.add('active');
            btn.textContent = '♥';
        }
        
        localStorage.setItem('wishlist', JSON.stringify(wishlist));
    });
});

// Modal functionality
const modal = document.getElementById('destinationModal');
const closeModal = document.getElementById('closeModal');

const destinationInfo = {
    'Lonavala': {
        description: 'A popular hill station known for its scenic beauty and pleasant weather.',
        activities: ['Visit Bhushi Dam', 'Explore Karla and Bhaja Caves', 'Tiger Point viewpoint', 'Try local chikki'],
        bestTime: 'June to September (Monsoon) for lush greenery'
    },
    'Ajanta & Ellora': {
        description: 'UNESCO World Heritage Sites featuring ancient rock-cut cave temples.',
        activities: ['Explore 30 rock-cut Buddhist caves at Ajanta', 'Visit Kailasa temple at Ellora', 'Photography', 'Learn about ancient Indian art'],
        bestTime: 'October to March'
    },
    'Konkan Coast': {
        description: 'Pristine beaches and coastal beauty stretching along the Arabian Sea.',
        activities: ['Beach hopping', 'Water sports', 'Try Konkani cuisine', 'Visit Ganpatipule temple'],
        bestTime: 'October to March'
    },
    'Mahabaleshwar': {
        description: 'Hill station famous for strawberries and breathtaking viewpoints.',
        activities: ['Visit Arthur\'s Seat', 'Strawberry picking', 'Boating at Venna Lake', 'Explore Pratapgad Fort'],
        bestTime: 'October to June'
    }
};

document.querySelectorAll('.card').forEach(card => {
    card.addEventListener('click', () => {
        const destination = card.getAttribute('data-destination');
        const info = destinationInfo[destination];
        
        document.getElementById('modalTitle').textContent = destination;
        document.getElementById('modalDescription').textContent = info.description;
        
        const activitiesList = document.getElementById('modalActivities');
        activitiesList.innerHTML = '';
        info.activities.forEach(activity => {
            const li = document.createElement('li');
            li.textContent = activity;
            activitiesList.appendChild(li);
        });
        
        document.getElementById('modalBestTime').textContent = info.bestTime;
        
        modal.style.display = 'flex';
    });
});

closeModal.addEventListener('click', () => {
    modal.style.display = 'none';
});

window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
});

// Form submission
const travelForm = document.getElementById('travelForm');
const successMsg = document.getElementById('successMsg');

travelForm.addEventListener('submit', (e) => {
    e.preventDefault();
    successMsg.style.display = 'block';
    
    setTimeout(() => {
        successMsg.style.display = 'none';
        travelForm.reset();
    }, 3000);
});

// Smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});
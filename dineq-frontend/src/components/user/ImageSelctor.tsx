// import React, { useState, useEffect } from 'react'
// import Image from 'next/image'

// const ImageSelector = ({ isOpen, onClose, onSelect, gender = 'male', number = 30 }) => {
//   const [tab, setTab] = useState('avatar')
//   const [avatars, setAvatars] = useState([])

//   useEffect(() => {
//     if (tab === 'avatar') {
//       fetch(`https://g6-menumate-1.onrender.com/api/v1/users/avatar-options?number=${number}&gender=${gender}`)
//         .then(res => res.json())
//         .then(data => setAvatars(data.data.avatars))
//         .catch(err => console.error('Avatar fetch error:', err))
//     }
//   }, [tab, gender, number])

//   const handleAvatarSelect = (url) => {
//     onSelect(url)
//     onClose()
//   }

//   const handleFileUpload = (e) => {
//     const file = e.target.files[0]
//     if (file) {
//       const reader = new FileReader()
//       reader.onload = () => {
//         onSelect(reader.result)
//         onClose()
//       }
//       reader.readAsDataURL(file)
//     }
//   }

//   if (!isOpen) return null

//   return (
//     <div className="modal-overlay">
//       <div className="modal">
//         <h2>Choose Your Profile Image</h2>
//         <div className="tabs">
//           <button onClick={() => setTab('avatar')} className={tab === 'avatar' ? 'active' : ''}>Choose Avatar</button>
//           <button onClick={() => setTab('upload')} className={tab === 'upload' ? 'active' : ''}>Upload File</button>
//         </div>

//         {tab === 'avatar' && (
//           <div className="avatar-grid">
//             {avatars.map((avatar) => (
//               <Image
//                 key={avatar.id}
//                 src={avatar.url}
//                 alt={`Avatar ${avatar.id}`}
//                 onClick={() => handleAvatarSelect(avatar.url)}
//                 className="avatar-option"
//               />
//             ))}
//           </div>
//         )}

//         {tab === 'upload' && (
//           <div className="upload-section">
//             <input type="file" accept="image/*" onChange={handleFileUpload} />
//           </div>
//         )}

//         <button onClick={onClose} className="close-btn">Cancel</button>
//       </div>
//     </div>
//   )
// }

// export default ImageSelector
